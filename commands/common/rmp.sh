source "${EPX_HOME}/helpers/header.sh"

# No external dependencies needed - using only shell built-ins

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

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  echo "Error: No files or directories specified" >&2
  show_usage
  exit 1
fi

count_files() {
  local target="$1"

  if [[ -f "$target" ]]; then
    echo 1
  elif [[ -d "$target" ]]; then
    find "$target" -type f 2>/dev/null | wc -l
  else
    echo 0
  fi
}

get_total_size() {
  local target="$1"

  if [[ -f "$target" ]]; then
    wc -c < "$target" 2>/dev/null || echo 0
  elif [[ -d "$target" ]]; then
    # Simplified: just estimate based on file count for display purposes
    local file_count=$(find "$target" -type f 2>/dev/null | wc -l)
    echo $((file_count * 1024))  # Rough estimate: 1KB per file average
  else
    echo 0
  fi
}

format_size() {
  local size="$1"

  if [[ "$size" -eq 0 ]]; then
    echo "0 bytes"
    return
  fi

  # Simple size formatting without numfmt
  local units=("bytes" "KB" "MB" "GB" "TB")
  local unit_index=0
  local formatted_size="$size"

  while [[ "$formatted_size" -gt 1024 && "$unit_index" -lt 4 ]]; do
    formatted_size=$((formatted_size / 1024))
    unit_index=$((unit_index + 1))
  done

  echo "${formatted_size} ${units[$unit_index]}"
}

validate_target() {
  local target="$1"

  if [[ ! -e "$target" ]]; then
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

remove_with_progress() {
  local target="$1"
  local file_count="$2"

  echo "  Removing: $target"

  if [[ -f "$target" ]]; then
    # Simple file removal
    rm -f "$target"
  elif [[ -d "$target" ]]; then
    # Directory removal with basic progress indication
    if [[ "$file_count" -gt 100 ]]; then
      echo "  Removing $file_count files..."
      # For large directories, show some progress
      local removed=0
      local progress_interval=$((file_count / 10))
      if [[ "$progress_interval" -lt 1 ]]; then
        progress_interval=1
      fi

      find "$target" -type f -print0 | while IFS= read -r -d '' file; do
        rm -f "$file"
        removed=$((removed + 1))
        if [[ $((removed % progress_interval)) -eq 0 ]]; then
          echo "    Progress: $removed/$file_count files removed"
        fi
      done

      # Remove empty directories
      find "$target" -depth -type d -delete 2>/dev/null || rm -rf "$target"
    else
      # For small directories, just remove directly
      rm -rf "$target"
    fi
  else
    rm -rf "$target"
  fi
}

perform_removal_operation() {
  local stripped_target="$1"
  local file_count="$2"
  local total_size="$3"

  echo "Removing '$stripped_target'..."
  remove_with_progress "$stripped_target" "$file_count"
}

verify_removal_success() {
  local stripped_target="$1"

  if [[ ! -e "$stripped_target" ]]; then
    echo "✓ Successfully removed '$stripped_target'"
    return 0
  else
    echo "✗ Failed to completely remove '$stripped_target'" >&2
    return 1
  fi
}

remove_target() {
  local target="$1"

  if ! validate_target "$target"; then
    return 0
  fi

  local stripped_target="${target%/}"

  echo "Analyzing '$stripped_target'..."
  local file_count=$(count_files "$stripped_target")
  local total_size=$(get_total_size "$stripped_target")

  if [[ "$file_count" -eq 0 ]]; then
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

  if [[ ${#failed_targets[@]} -eq 0 ]]; then
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

  if [[ "$FORCE_MODE" = false ]]; then
    if [[ $total_targets -gt 20 ]]; then
      echo "About to permanently remove $total_targets item(s)."
      echo "Too many items to list individually. First 10 items:"
      local count=0
      for target in "${TARGETS[@]}"; do
        count=$((count + 1))
        if [[ $count -le 10 ]]; then
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

    if ! remove_target "$target"; then
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
