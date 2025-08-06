#!/bin/bash

set -euo pipefail

source "${EPX_HOME}/helpers/check-command-installed.sh"
_cci pv find du

show_usage() {
  echo "Usage: move [OPTIONS] SOURCE... DESTINATION"
  echo "Move files and directories with detailed progress indication"
  echo ""
  echo "Options:"
  echo "  -f, --force         Do not prompt before overwriting"
  echo "  -n, --no-clobber    Do not overwrite an existing file"
  echo "  -h, --help          Show this help message"
  echo ""
  echo "Examples:"
  echo "  move file.txt /tmp/"
  echo "  move -f file1.txt file2.txt /destination/"
  echo "  move -n important.txt important_backup.txt"
  echo "  move directory/ /new/location/"
}

FORCE=false
NO_CLOBBER=false
SOURCES=()
DESTINATION=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--force)
      FORCE=true
      NO_CLOBBER=false
      shift
      ;;
    -n|--no-clobber)
      NO_CLOBBER=true
      FORCE=false
      shift
      ;;
    -h|--help)
      show_usage
      exit 0
      ;;
    -*)
      echo "Error: Unknown option $1" >&2
      show_usage
      exit 1
      ;;
    *)
      if [ ${#SOURCES[@]} -eq 0 ] || [ -z "$DESTINATION" ]; then
        if [ -z "$DESTINATION" ] && [ ${#SOURCES[@]} -gt 0 ]; then
          DESTINATION="$1"
        else
          SOURCES+=("$1")
        fi
      else
        DESTINATION="$1"
      fi
      shift
      ;;
  esac
done

if [ ${#SOURCES[@]} -eq 0 ]; then
  echo "Error: No source files specified" >&2
  show_usage
  exit 1
fi

if [ -z "$DESTINATION" ]; then
  echo "Error: No destination specified" >&2
  show_usage
  exit 1
fi

count_files() {
  local target="$1"

  if [ -f "$target" ]; then
    echo 1
  elif [ -d "$target" ]; then
    find "$target" -type f 2>/dev/null | wc -l
  else
    echo 0
  fi
}

get_total_size() {
  local target="$1"

  if [ -f "$target" ]; then
    stat -c%s "$target" 2>/dev/null || echo 0
  elif [ -d "$target" ]; then
    du -sb "$target" 2>/dev/null | cut -f1 || echo 0
  else
    echo 0
  fi
}

format_size() {
  local size="$1"

  if [ "$size" -gt 0 ]; then
    numfmt --to=iec-i --suffix=B "$size" 2>/dev/null || echo "${size} bytes"
  else
    echo "0 bytes"
  fi
}

should_overwrite() {
  local source="$1"
  local dest="$2"

  if [ ! -e "$dest" ]; then
    return 0
  fi

  if [ "$NO_CLOBBER" = true ]; then
    echo "Skipping '$dest' (no-clobber mode)"
    return 1
  fi

  return 0
}

get_user_confirmation() {
  local items="$1"

  read -p "Are you sure you want to move $items? [y/N] " confirm
  case "$confirm" in
    [yY][eE][sS]|[yY])
      return 0
      ;;
    *)
      echo "Cancelled."
      return 1
      ;;
  esac
}

move_file() {
  local source_file="$1"
  local dest_file="$2"
  local file_size="$3"

  if [ "$file_size" -gt 0 ]; then
    if pv "$source_file" > "$dest_file"; then
      /usr/bin/rm "$source_file"
    else
      echo "Error: Failed to copy '$source_file'" >&2
      return 1
    fi
  else
    echo "  Processing empty file..." | pv -q -L 10
    /usr/bin/mv "$source_file" "$dest_file" 2>/dev/null
  fi
}

move_directory() {
  local source="$1"
  local dest="$2"
  local file_count="$3"

  echo "  Moving directory: $(basename "$source")"
  local current_file=0
  local source_len=${#source}

  mkdir -p "$dest"

  find "$source" -type d -print0 | while IFS= read -r -d '' dir; do
    local relative_path="${dir:$source_len}"
    relative_path="${relative_path#/}"
    if [ -n "$relative_path" ]; then
      local dest_dir="$dest/$relative_path"
      mkdir -p "$dest_dir"
    fi
  done

  find "$source" -type f -print0 | while IFS= read -r -d '' file; do
    current_file=$((current_file + 1))
    local relative_path="${file:$source_len}"
    relative_path="${relative_path#/}"
    local dest_file="$dest/$relative_path"
    local dest_file_dir=$(dirname "$dest_file")

    mkdir -p "$dest_file_dir"

    if should_overwrite "$file" "$dest_file"; then
      echo "    [$current_file/$file_count] Moving: $relative_path"
      local file_size=$(stat -c%s "$file" 2>/dev/null || echo 0)

      if [ "$file_size" -gt 0 ]; then
        if [ "$file_size" -gt 1048576 ]; then
          if pv "$file" > "$dest_file"; then
            /usr/bin/rm "$file"
          else
            echo "Error: Failed to move '$file'" >&2
            return 1
          fi
        else
          if pv -q "$file" > "$dest_file"; then
            /usr/bin/rm "$file"
          else
            echo "Error: Failed to move '$file'" >&2
            return 1
          fi
        fi
      else
        echo "      Processing empty file..." | pv -q -L 10
        if /usr/bin/cp "$file" "$dest_file"; then
          /usr/bin/rm "$file"
        else
          echo "Error: Failed to move empty file '$file'" >&2
          return 1
        fi
      fi
    fi
  done

  echo "  Cleaning up empty directories..."
  find "$source" -depth -type d -empty -delete 2>/dev/null || true
  rmdir "$source" 2>/dev/null || true
}

get_destination_path() {
  local source="$1"
  local dest="$2"

  if [ -d "$dest" ]; then
    echo "$dest/$(basename "$source")"
  else
    echo "$dest"
  fi
}

validate_source() {
  local source="$1"

  if [ ! -e "$source" ]; then
    echo "Error: '$source' does not exist" >&2
    return 1
  fi

  return 0
}

validate_move() {
  local source="$1"
  local dest_path="$2"

  if [ -d "$source" ] && [[ "$dest_path" == "$source"/* ]]; then
    echo "Error: Cannot move '$source' into itself" >&2
    return 1
  fi

  if [ "$source" -ef "$dest_path" ] 2>/dev/null; then
    echo "Error: '$source' and '$dest_path' are the same file" >&2
    return 1
  fi

  return 0
}

perform_move_operation() {
  local source="$1"
  local dest_path="$2"

  echo "Analyzing '$source'..."
  local file_count=$(count_files "$source")
  local total_size=$(get_total_size "$source")

  if [ "$file_count" -eq 0 ] && [ -d "$source" ]; then
    echo "Warning: No files found in '$source'" >&2
    file_count=1
  fi

  echo "Source: $source"
  echo "Destination: $dest_path"
  echo "Files to move: $file_count"
  echo "Total size: $(format_size "$total_size")"

  if ! validate_move "$source" "$dest_path"; then
    return 1
  fi

  if [ -f "$source" ]; then
    if should_overwrite "$source" "$dest_path"; then
      echo "Moving file: $source -> $dest_path"
      move_file "$source" "$dest_path" "$total_size"
      echo "✓ Successfully moved file"
    fi

  elif [ -d "$source" ]; then
    echo "Moving directory: $source -> $dest_path"
    move_directory "$source" "$dest_path" "$file_count"
    echo "✓ Successfully moved directory"
  fi
}

move_with_progress() {
  local source="$1"

  if ! validate_source "$source"; then
    return 1
  fi

  local dest_path=$(get_destination_path "$source" "$DESTINATION")

  perform_move_operation "$source" "$dest_path"
}

show_final_summary() {
  local total_sources="$1"
  local failed_sources=("${@:2}")

  echo
  echo "========================================"
  echo "Move operation completed!"
  echo "Processed: $total_sources source(s)"

  if [ ${#failed_sources[@]} -eq 0 ]; then
    echo "✓ All sources moved successfully"
    return 0
  else
    echo "✗ Failed to move ${#failed_sources[@]} source(s):" >&2
    for failed in "${failed_sources[@]}"; do
      echo "  - $failed" >&2
    done
    return 1
  fi
}

main() {
  local total_sources=${#SOURCES[@]}
  local current=0
  local failed_sources=()

  if [ "$FORCE" = false ]; then
    if [ $total_sources -gt 20 ]; then
      echo "About to move $total_sources item(s)."
      echo "Too many items to list individually. First 10 items:"
      local count=0
      for source in "${SOURCES[@]}"; do
        count=$((count + 1))
        if [ $count -le 10 ]; then
          echo "  - $source"
        else
          echo "  ... and $((total_sources - 10)) more items"
          break
        fi
      done
    else
      echo "About to move $total_sources item(s):"
      for source in "${SOURCES[@]}"; do
        echo "  - $source"
      done
    fi
    echo

    if ! get_user_confirmation "these $total_sources item(s)"; then
      echo "Operation cancelled by user."
      exit 1
    fi
  else
    echo "Force mode: Moving $total_sources source(s) without confirmation..."
  fi

  echo "Starting move operation with $total_sources source(s)..."

  for source in "${SOURCES[@]}"; do
    current=$((current + 1))
    echo
    echo "[$current/$total_sources] Processing: $source"
    echo "----------------------------------------"

    if ! move_with_progress "$source"; then
      failed_sources+=("$source")
    fi
  done

  if show_final_summary "$total_sources" "${failed_sources[@]}"; then
    exit 0
  else
    exit 1
  fi
}

main
