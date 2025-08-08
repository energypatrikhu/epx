#!/bin/bash

set -euo pipefail

source "${EPX_HOME}/helpers/check-command-installed.sh"
_cci pv find du

show_usage() {
  echo "Usage: rmp [OPTIONS] <file/directory> [additional files/directories...]"
  echo "Remove files and directories permanently with detailed progress indication"
  echo ""
  echo "Options:"
  echo "  -f, --force    Skip confirmation prompt"
  echo "  -h, --help     Show this help message"
  echo ""
  echo "Supports glob patterns like *.txt, *.log, etc."
  echo "Examples:"
  echo "  rmp file.txt"
  echo "  rmp -f *.log"
  echo "  rmp --force directory/"
  echo "  rmp file1.txt file2.txt directory/"
}

FORCE_MODE=false
TARGETS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--force)
      FORCE_MODE=true
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
      TARGETS+=("$1")
      shift
      ;;
  esac
done

if [ ${#TARGETS[@]} -eq 0 ]; then
  echo "Error: No files or directories specified" >&2
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

validate_target() {
  local target="$1"

  if [ ! -e "$target" ]; then
    echo "Warning: '$target' does not exist, skipping..." >&2
    return 1
  fi

  case "$target" in
    "/" | "/*")
      echo "Error: Cannot remove root directory: $target" >&2
      return 1
      ;;
  esac

  return 0
}

show_removal_summary() {
  local stripped_target="$1"
  local file_count="$2"
  local total_size="$3"

  echo "Target: $stripped_target"
  echo "Files to remove: $file_count"
  echo "Total size: $(format_size "$total_size")"
}

get_user_confirmation() {
  local stripped_target="$1"

  read -p "Are you sure you want to permanently delete '$stripped_target'? [y/N] " confirm
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

remove_file() {
  local source_file="$1"
  local file_size="$2"

  echo "  Removing: $source_file"
  if [ "$file_size" -gt 0 ]; then
    pv "$source_file" > /dev/null && /usr/bin/rm -f "$source_file"
  else
    echo "  Processing empty file..." | pv -q -L 10
    rm -f "$source_file"
  fi
}

remove_directory_contents() {
  local source_dir="$1"
  local file_count="$2"

  local current_file=0

  find "$source_dir" -type f -print0 | while IFS= read -r -d '' file; do
    current_file=$((current_file + 1))
    local relative_path="${file#$source_dir/}"

    echo "  [$current_file/$file_count] Removing: $relative_path"
    local file_size=$(stat -c%s "$file" 2>/dev/null || echo 0)

    if [ "$file_size" -gt 0 ]; then
      pv "$file" > /dev/null && /usr/bin/rm -f "$file"
    else
      echo "    Processing empty file..." | pv -q -L 10
      rm -f "$file"
    fi
  done | pv -l -s "$file_count" > /dev/null
}

remove_empty_directories() {
  local source_dir="$1"

  echo "  Cleaning up empty directories..."
  local dir_count=$(find "$source_dir" -depth -type d 2>/dev/null | wc -l)

  find "$source_dir" -depth -type d -print -delete 2>/dev/null | while read -r dir; do
    echo "    Removing directory: ${dir#$source_dir/}"
  done | pv -l -s "$dir_count" > /dev/null
}

perform_removal_operation() {
  local stripped_target="$1"
  local file_count="$2"
  local total_size="$3"

  echo "Removing '$stripped_target'..."

  if [ -f "$stripped_target" ]; then
    echo "Removing file: $stripped_target"
    remove_file "$stripped_target" "$total_size"

  elif [ -d "$stripped_target" ]; then
    echo "Removing directory: $stripped_target"

    if [ "$file_count" -gt 0 ]; then
      remove_directory_contents "$stripped_target" "$file_count"

      remove_empty_directories "$stripped_target"
    else
      echo "  Removing empty directory..."
      rm -rf "$stripped_target"
    fi
  else
    echo "Removing: $stripped_target"
    rm -rf "$stripped_target"
  fi
}

verify_removal_success() {
  local stripped_target="$1"

  if [ ! -e "$stripped_target" ]; then
    echo "✓ Successfully removed '$stripped_target'"
    return 0
  else
    echo "✗ Failed to completely remove '$stripped_target'" >&2
    return 1
  fi
}

remove_with_progress() {
  local target="$1"

  if ! validate_target "$target"; then
    return 0
  fi

  local stripped_target="${target%/}"

  echo "Analyzing '$stripped_target'..."
  local file_count=$(count_files "$stripped_target")
  local total_size=$(get_total_size "$stripped_target")

  if [ "$file_count" -eq 0 ]; then
    echo "Warning: No files found in '$stripped_target'" >&2
    return 0
  fi

  show_removal_summary "$stripped_target" "$file_count" "$total_size"

  perform_removal_operation "$stripped_target" "$file_count" "$total_size"

  verify_removal_success "$stripped_target"
}

show_final_summary() {
  local total_targets="$1"
  local failed_targets=("${@:2}")

  echo
  echo "========================================"
  echo "Removal completed!"
  echo "Processed: $total_targets target(s)"

  if [ ${#failed_targets[@]} -eq 0 ]; then
    echo "✓ All targets removed successfully"
    return 0
  else
    echo "✗ Failed to remove ${#failed_targets[@]} target(s):" >&2
    for failed in "${failed_targets[@]}"; do
      echo "  - $failed" >&2
    done
    return 1
  fi
}

main() {
  local total_targets=${#TARGETS[@]}
  local current=0
  local failed_targets=()

  if [ "$FORCE_MODE" = false ]; then
    if [ $total_targets -gt 20 ]; then
      echo "About to permanently remove $total_targets item(s)."
      echo "Too many items to list individually. First 10 items:"
      local count=0
      for target in "${TARGETS[@]}"; do
        count=$((count + 1))
        if [ $count -le 10 ]; then
          echo "  - $target"
        else
          echo "  ... and $((total_targets - 10)) more items"
          break
        fi
      done
    else
      echo "About to permanently remove $total_targets item(s):"
      for target in "${TARGETS[@]}"; do
        echo "  - $target"
      done
    fi
    echo

    if ! get_user_confirmation "these $total_targets item(s)"; then
      echo "Operation cancelled by user."
      exit 1
    fi
  else
    echo "Force mode: Removing $total_targets item(s) without confirmation..."
  fi

  for target in "${TARGETS[@]}"; do
    current=$((current + 1))
    echo
    echo "[$current/$total_targets] Processing: $target"
    echo "----------------------------------------"

    if ! remove_with_progress "$target"; then
      failed_targets+=("$target")
    fi
  done

  if show_final_summary "$total_targets" "${failed_targets[@]}"; then
    exit 0
  else
    exit 1
  fi
}

main
