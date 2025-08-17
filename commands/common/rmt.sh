_cci rsync

# Load configuration
if [[ ! -f "${EPX_HOME}/.config/rmt.config" ]]; then
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

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  echo "Error: No files or directories specified" >&2
  show_usage
  exit 1
fi

is_excluded_from_trash() {
  local target="$1"

  local abs_target=$(realpath "$target" 2>/dev/null || readlink -f "$target" 2>/dev/null || echo "$target")

  # Check if TRASH_EXCLUDE is set and not empty
  if [[ -n "$TRASH_EXCLUDE" ]]; then
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
  if [[ -z "$trash_dir" ]]; then
    trash_dir="$TRASH_FALLBACK"
  fi

  echo "$trash_dir"
}

get_target_info() {
  local target="$1"

  if [[ -f "$target" ]]; then
    echo "1 $(wc -c < "$target" 2>/dev/null || echo 0)"
  elif [[ -d "$target" ]]; then
    # Get both count and size in one pass
    local file_count=0
    local total_size=0
    while IFS= read -r -d '' file; do
      if [[ -f "$file" ]]; then
        file_count=$((file_count + 1))
        local size=$(wc -c < "$file" 2>/dev/null || echo 0)
        total_size=$((total_size + size))
      fi
    done < <(find "$target" -type f -print0 2>/dev/null)
    echo "$file_count $total_size"
  else
    echo "0 0"
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
      echo "Error: Cannot move root directory to trash: $target" >&2
      return 1
      ;;
  esac

  return 0
}

ensure_trash_dir() {
  local trash_dir="$1"

  if [[ ! -d "$trash_dir" ]]; then
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

  while [[ -e "$trash_target" ]]; do
    trash_target="$trash_dir/${basename}.${counter}"
    counter=$((counter + 1))
  done

  echo "$trash_target"
}

show_summary() {
  local target="$1"
  local file_count="$2"
  local total_size="$3"
  local destination="$4"
  local is_delete="${5:-false}"

  echo "Target: $target"
  echo "Files: $file_count"
  echo "Size: $(format_size "$total_size")"

  if [[ "$is_delete" == "true" ]]; then
    echo "⚠️  WARNING: This will PERMANENTLY DELETE the files (not moved to trash)"
  else
    echo "Destination: $destination"
  fi
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

move_with_rsync() {
  local source="$1"
  local dest="$2"

  echo

  if rsync -rxvuaP --progress --remove-source-files "$source" "$dest"; then
    # Clean up empty directories
    [[ -d "$source" ]] && find "$source" -depth -type d -empty -delete 2>/dev/null
    [[ -d "$source" ]] && (rmdir "$source" 2>/dev/null || rm -rf "$source")

    echo
    return 0
  else
    echo "Error: Failed to move '$source'" >&2
    return 1
  fi
}

delete_permanently() {
  local target="$1"
  local file_count="$2"

  echo "Permanently deleting '$target'..."

  if [[ "$file_count" -gt 50 ]]; then
    # Show progress for large deletions
    local removed=0
    local progress_interval=$((file_count / 10))
    [[ "$progress_interval" -lt 1 ]] && progress_interval=1

    find "$target" -type f -print0 | while IFS= read -r -d '' file; do
      rm -f "$file"
      removed=$((removed + 1))
      if [[ $((removed % progress_interval)) -eq 0 ]]; then
        echo "  Progress: $removed/$file_count files deleted"
      fi
    done
    find "$target" -depth -type d -delete 2>/dev/null
  else
    # Direct removal for small targets
    rm -rf "$target"
  fi
}

verify_operation() {
  local target="$1"
  local destination="$2"
  local is_delete="${3:-false}"

  if [[ "$is_delete" == "true" ]]; then
    if [[ ! -e "$target" ]]; then
      echo "✓ Successfully deleted '$target'"
      return 0
    else
      echo "✗ Failed to delete '$target'" >&2
      return 1
    fi
  else
    if [[ ! -e "$target" && -e "$destination" ]]; then
      echo "✓ Successfully moved '$target' to trash: $destination"
      return 0
    else
      echo "✗ Failed to move '$target' to trash" >&2
      return 1
    fi
  fi
}

process_target() {
  local target="$1"

  if ! validate_target "$target"; then
    return 0
  fi

  local stripped_target="${target%/}"
  echo "Analyzing '$stripped_target'..."

  # Get file count and size in one call
  local info=($(get_target_info "$stripped_target"))
  local file_count=${info[0]}
  local total_size=${info[1]}

  if is_excluded_from_trash "$stripped_target"; then
    echo "⚠️  Target is in TRASH_EXCLUDE - will be permanently deleted"
    show_summary "$stripped_target" "$file_count" "$total_size" "" "true"
    delete_permanently "$stripped_target" "$file_count"
    verify_operation "$stripped_target" "" "true"
  else
    local trash_dir=$(get_trash_dir "$stripped_target")
    if ! ensure_trash_dir "$trash_dir"; then
      return 1
    fi

    local basename=$(basename "$stripped_target")
    local trash_target=$(generate_unique_trash_target "$trash_dir" "$basename")

    show_summary "$stripped_target" "$file_count" "$total_size" "$trash_target"
    move_with_rsync "$stripped_target" "$trash_target"
    verify_operation "$stripped_target" "$trash_target"
  fi
}

show_final_summary() {
  local total_targets="$1"
  local failed_targets=("${@:2}")

  echo
  echo "========================================"
  echo "Operation completed!"
  echo "Processed: $total_targets target(s)"

  if [[ ${#failed_targets[@]} -eq 0 ]]; then
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

  if [[ "$FORCE_MODE" = false ]]; then
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
    if [[ ${#trash_targets[@]} -gt 0 ]]; then
      echo "Items to move to trash (${#trash_targets[@]}):"
      for target in "${trash_targets[@]}"; do
        echo "  📁 $target"
      done
    fi

    if [[ ${#excluded_targets[@]} -gt 0 ]]; then
      echo
      echo "⚠️  Items to PERMANENTLY DELETE (${#excluded_targets[@]}):"
      for target in "${excluded_targets[@]}"; do
        echo "  🗑️  $target (excluded from trash)"
      done
    fi

    echo

    # Get confirmation for trash items
    if [[ ${#trash_targets[@]} -gt 0 ]]; then
      if ! get_user_confirmation "${#trash_targets[@]}"; then
        echo "Operation cancelled by user."
        exit 1
      fi
    fi

    # Get confirmation for permanent deletion
    if [[ ${#excluded_targets[@]} -gt 0 ]]; then
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
