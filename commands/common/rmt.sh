#!/bin/bash

set -euo pipefail

source "${EPX_HOME}/helpers/check-command-installed.sh"
_cci pv find du

# Load configuration
if [ ! -f "${EPX_HOME}/.config/rmt.config" ]; then
  echo "Error: Config file not found, please create one at ${EPX_HOME}/.config/rmt.config" >&2
  exit 1
fi
. "${EPX_HOME}/.config/rmt.config"

show_usage() {
  echo "Usage: rmt [OPTIONS] <file/directory> [additional files/directories...]"
  echo "Move files and directories to trash with detailed progress indication"
  echo ""
  echo "Options:"
  echo "  -f, --force    Skip confirmation prompt"
  echo "  -h, --help     Show this help message"
  echo ""
  echo "Note: Files in paths matching TRASH_EXCLUDE will be permanently deleted"
  echo "instead of moved to trash. This action cannot be undone!"
  echo ""
  echo "Supports glob patterns like *.txt, *.log, etc."
  echo "Examples:"
  echo "  rmt file.txt"
  echo "  rmt -f *.log"
  echo "  rmt --force directory/"
  echo "  rmt file1.txt file2.txt directory/"
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

is_excluded_from_trash() {
  local target="$1"

  local abs_target=$(realpath "$target" 2>/dev/null || readlink -f "$target" 2>/dev/null || echo "$target")

  # Check if TRASH_EXCLUDE is set and not empty
  if [ -n "$TRASH_EXCLUDE" ]; then
    local IFS=' '
    for exclude_path in $TRASH_EXCLUDE; do
      if [[ "$abs_target" == "$exclude_path"* ]]; then
        return 0  # true - should be excluded
      fi
    done
  fi

  return 1  # false - not excluded
}

get_trash_dir() {
  local target="$1"

  local abs_target=$(realpath "$target" 2>/dev/null || readlink -f "$target" 2>/dev/null || echo "$target")
  local abs_target_dir=$(dirname "$abs_target")

  # Parse TRASH_DIRS configuration
  local trash_dir=""
  local IFS=' '
  for mapping in $TRASH_DIRS; do
    local source_path="${mapping%:*}"
    local trash_path="${mapping#*:}"

    # starts with abs_target_dir and matches the source_path
    if [[ "$abs_target" == "$source_path"* && "$source_path" =~ ^"${abs_target_dir}" ]]; then
      trash_dir="$trash_path"
      break
    fi
  done

  # If no specific mapping found, use fallback
  if [ -z "$trash_dir" ]; then
    trash_dir="$TRASH_FALLBACK"
  fi

  echo "$trash_dir"
}

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
      echo "Error: Cannot move root directory to trash: $target" >&2
      return 1
      ;;
  esac

  return 0
}

ensure_trash_dir() {
  local trash_dir="$1"

  if [ ! -d "$trash_dir" ]; then
    echo "Creating trash directory: $trash_dir"
    if ! mkdir -p "$trash_dir"; then
      echo "Error: Failed to create trash directory: $trash_dir" >&2
      return 1
    fi
  fi
  return 0
}

generate_unique_trash_target() {
  local trash_dir="$1"
  local basename="$2"
  local trash_target="$trash_dir/$basename"
  local counter=1

  while [ -e "$trash_target" ]; do
    trash_target="$trash_dir/${basename}.${counter}"
    counter=$((counter + 1))
  done

  echo "$trash_target"
}

show_move_summary() {
  local stripped_target="$1"
  local file_count="$2"
  local total_size="$3"
  local trash_target="$4"

  echo "Target: $stripped_target"
  echo "Files to move: $file_count"
  echo "Destination: $trash_target"
  echo "Total size: $(format_size "$total_size")"
}

show_delete_summary() {
  local stripped_target="$1"
  local file_count="$2"
  local total_size="$3"

  echo "Target: $stripped_target"
  echo "Files to permanently delete: $file_count"
  echo "Total size: $(format_size "$total_size")"
  echo "⚠️  WARNING: This will PERMANENTLY DELETE the files (not moved to trash)"
}

get_user_confirmation() {
  local stripped_target="$1"

  read -p "Are you sure you want to move '$stripped_target' item(s) to trash? [y/N] " confirm
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

get_user_confirmation_delete() {
  local stripped_target="$1"

  echo "⚠️  DANGER: This will PERMANENTLY DELETE '$stripped_target' item(s) permanently!"
  echo "⚠️  This action CANNOT be undone!"
  read -p "Type 'DELETE' (in capitals) to confirm permanent deletion: " confirm
  case "$confirm" in
    DELETE)
      return 0
      ;;
    *)
      echo "Cancelled. Did not receive 'DELETE' confirmation."
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

move_directory_contents() {
  local source_dir="$1"
  local dest_dir="$2"
  local file_count="$3"

  local current_file=0

  find "$source_dir" -type f -print0 | while IFS= read -r -d '' file; do
    current_file=$((current_file + 1))
    local relative_path="${file#$source_dir/}"
    local dest_file="$dest_dir/$relative_path"
    local dest_file_dir=$(dirname "$dest_file")

    mkdir -p "$dest_file_dir"

    echo "  [$current_file/$file_count] Moving: $relative_path"
    local file_size=$(stat -c%s "$file" 2>/dev/null || echo 0)

    move_file "$file" "$dest_file" "$file_size"
  done
}

cleanup_empty_directories() {
  local source_dir="$1"

  echo "  Cleaning up empty directories..."
  find "$source_dir" -depth -type d -empty -delete 2>/dev/null | while read -r dir; do
    echo "    Removed empty directory: ${dir#$source_dir/}"
  done | pv -l > /dev/null

  rmdir "$source_dir" 2>/dev/null || true
}

perform_move_operation() {
  local stripped_target="$1"
  local trash_target="$2"
  local file_count="$3"
  local total_size="$4"

  echo "Moving '$stripped_target' to trash..."

  if [ -f "$stripped_target" ]; then

    echo "Moving file: $stripped_target -> $trash_target"
    move_file "$stripped_target" "$trash_target" "$total_size"

  elif [ -d "$stripped_target" ]; then

    echo "Moving directory: $stripped_target -> $trash_target"

    if [ "$file_count" -gt 0 ]; then

      mkdir -p "$trash_target"

      move_directory_contents "$stripped_target" "$trash_target" "$file_count"

      cleanup_empty_directories "$stripped_target"
    else

      echo "  Moving empty directory..."
      /usr/bin/mv "$stripped_target" "$trash_target" 2>/dev/null
    fi
  else

    echo "Moving: $stripped_target -> $trash_target"
    /usr/bin/mv "$stripped_target" "$trash_target" 2>/dev/null
  fi
}

perform_delete_operation() {
  local stripped_target="$1"
  local file_count="$2"

  echo "Permanently deleting '$stripped_target'..."

  if [ -f "$stripped_target" ]; then
    echo "Deleting file: $stripped_target"
    /usr/bin/rm -f "$stripped_target"
  elif [ -d "$stripped_target" ]; then
    echo "Deleting directory: $stripped_target"
    if [ "$file_count" -gt 0 ]; then
      echo "  Deleting $file_count files..."
      /usr/bin/rm -rf "$stripped_target" | pv -l > /dev/null
    else
      echo "  Deleting empty directory..."
      /usr/bin/rmdir "$stripped_target" 2>/dev/null
    fi
  else
    echo "Deleting: $stripped_target"
    /usr/bin/rm -rf "$stripped_target"
  fi
}

verify_move_success() {
  local stripped_target="$1"
  local trash_target="$2"

  if [ ! -e "$stripped_target" ] && [ -e "$trash_target" ]; then
    echo "✓ Successfully moved '$stripped_target' to trash: $trash_target"
    return 0
  else
    echo "✗ Failed to move '$stripped_target' to trash" >&2
    return 1
  fi
}

verify_delete_success() {
  local stripped_target="$1"

  if [ ! -e "$stripped_target" ]; then
    echo "✓ Successfully deleted '$stripped_target' permanently"
    return 0
  else
    echo "✗ Failed to delete '$stripped_target'" >&2
    return 1
  fi
}

move_to_trash_with_progress() {
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

  local trash_dir=$(get_trash_dir "$stripped_target")
  if ! ensure_trash_dir "$trash_dir"; then
    return 1
  fi

  local basename=$(basename "$stripped_target")
  local trash_target=$(generate_unique_trash_target "$trash_dir" "$basename")

  show_move_summary "$stripped_target" "$file_count" "$total_size" "$trash_target"

  perform_move_operation "$stripped_target" "$trash_target" "$file_count" "$total_size"

  verify_move_success "$stripped_target" "$trash_target"
}

delete_permanently_with_progress() {
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

  show_delete_summary "$stripped_target" "$file_count" "$total_size"

  perform_delete_operation "$stripped_target" "$file_count"

  verify_delete_success "$stripped_target"
}

process_target() {
  local target="$1"

  if is_excluded_from_trash "$target"; then
    echo "⚠️  Target is in TRASH_EXCLUDE - will be permanently deleted"
    delete_permanently_with_progress "$target"
  else
    move_to_trash_with_progress "$target"
  fi
}

show_final_summary() {
  local total_targets="$1"
  local failed_targets=("${@:2}")

  echo
  echo "========================================"
  echo "Operation completed!"
  echo "Processed: $total_targets target(s)"

  if [ ${#failed_targets[@]} -eq 0 ]; then
    echo "✓ All targets processed successfully"
    return 0
  else
    echo "✗ Failed to process ${#failed_targets[@]} target(s):" >&2
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
    # Check if any targets will be permanently deleted
    local has_excluded=false
    local excluded_targets=()
    local trash_targets=()

    for target in "${TARGETS[@]}"; do
      if is_excluded_from_trash "$target"; then
        has_excluded=true
        excluded_targets+=("$target")
      else
        trash_targets+=("$target")
      fi
    done

    # Show summary
    if [ ${#trash_targets[@]} -gt 0 ]; then
      echo "Items to move to trash (${#trash_targets[@]}):"
      for target in "${trash_targets[@]}"; do
        echo "  📁 $target"
      done
    fi

    if [ ${#excluded_targets[@]} -gt 0 ]; then
      echo
      echo "⚠️  Items to PERMANENTLY DELETE (${#excluded_targets[@]}):"
      for target in "${excluded_targets[@]}"; do
        echo "  🗑️  $target (excluded from trash)"
      done
    fi

    echo

    # Get confirmation for trash items
    if [ ${#trash_targets[@]} -gt 0 ]; then
      if ! get_user_confirmation "${#trash_targets[@]}"; then
        echo "Operation cancelled by user."
        exit 1
      fi
    fi

    # Get confirmation for permanent deletion
    if [ ${#excluded_targets[@]} -gt 0 ]; then
      if ! get_user_confirmation_delete "${#excluded_targets[@]}"; then
        echo "Operation cancelled by user."
        exit 1
      fi
    fi

  else
    echo "Force mode: Processing $total_targets item(s) without confirmation..."
  fi

  for target in "${TARGETS[@]}"; do
    current=$((current + 1))
    echo
    echo "[$current/$total_targets] Processing: $target"
    echo "----------------------------------------"

    if ! process_target "$target"; then
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
