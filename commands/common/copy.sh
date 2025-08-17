_cci rsync

show_usage() {
  echo "Usage: copy [OPTIONS] SOURCE... DESTINATION"
  echo "Copy files and directories with detailed progress indication"
  echo ""
  echo "Options:"
  echo "  -f, --force         If an existing destination file cannot be opened, remove it and try again"
  echo "  -p, --preserve      Preserve the specified attributes (default: mode,ownership,timestamps)"
  echo "  -L, --dereference   Always follow symbolic links in SOURCE"
  echo "  -h, --help          Show this help message"
  echo ""
  echo "Examples:"
  echo "  copy file.txt /tmp/"
  echo "  copy -f file1.txt file2.txt /destination/"
  echo "  copy -p important.txt important_backup.txt"
}

FORCE=false
PRESERVE=""
DEREFERENCE=false
SOURCES=()
DESTINATION=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--force)
      FORCE=true
      shift
      ;;
    -p|--preserve)
      if [[ $2 == =* ]]; then
        PRESERVE="${2#=}"
        shift 2
      else
        PRESERVE="mode,ownership,timestamps"
        shift
      fi
      ;;
    --preserve=*)
      PRESERVE="${1#*=}"
      shift
      ;;
    -L|--dereference)
      DEREFERENCE=true
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
      if [[ ${#SOURCES[@]} -eq 0 ]] || [[ -z "${DESTINATION-}" ]]; then
        if [[ -z "${DESTINATION-}" ]] && [[ ${#SOURCES[@]} -gt 0 ]]; then
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

if [[ ${#SOURCES[@]} -eq 0 ]]; then
  echo "Error: No source files specified" >&2
  show_usage
  exit 1
fi

if [[ -z "${DESTINATION-}" ]]; then
  echo "Error: No destination specified" >&2
  show_usage
  exit 1
fi

get_target_info() {
  local target="$1"

  if [[ -f "$target" ]]; then
    echo "1 $(wc -c < "$target" 2>/dev/null || echo 0)"
  elif [[ -d "$target" ]]; then
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

  local units=("bytes" "KB" "MB" "GB" "TB")
  local unit_index=0
  local formatted_size="$size"

  while [[ "$formatted_size" -gt 1024 && "$unit_index" -lt 4 ]]; do
    formatted_size=$((formatted_size / 1024))
    unit_index=$((unit_index + 1))
  done

  echo "${formatted_size} ${units[$unit_index]}"
}

build_rsync_options() {
  local options=("-rxvuaP" "--progress")

  [[ "$FORCE" = true ]] && options+=("--force")
  [[ "$DEREFERENCE" = true ]] && options+=("-L")

  if [[ -n "$PRESERVE" ]]; then
    # Convert cp preserve format to rsync format
    case "$PRESERVE" in
      *mode*) options+=("--chmod=D755,F644") ;;
    esac
    case "$PRESERVE" in
      *ownership*) options+=("--owner" "--group") ;;
    esac
    case "$PRESERVE" in
      *timestamps*) options+=("--times") ;;
    esac
  fi

  printf '%s\n' "${options[@]}"
}

copy_with_rsync() {
  local source="$1"
  local dest="$2"

  echo

  # Build rsync options array
  local rsync_opts=()
  while IFS= read -r option; do
    rsync_opts+=("$option")
  done < <(build_rsync_options)

  # Use rsync for efficient copying with progress
  if rsync "${rsync_opts[@]}" "$source" "$dest"; then
    echo
    return 0
  else
    echo "Error: Failed to copy '$source'" >&2
    return 1
  fi
}

get_user_confirmation() {
  local items="$1"

  read -p "Are you sure you want to copy $items? [y/N] " confirm
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

process_source() {
  local source="$1"

  if [[ ! -e "$source" ]]; then
    echo "Error: '$source' does not exist" >&2
    return 1
  fi

  local dest_path
  if [[ -d "$DESTINATION" ]]; then
    dest_path="$DESTINATION/$(basename "$source")"
  else
    dest_path="$DESTINATION"
  fi

  echo "Analyzing '$source'..."
  local info=($(get_target_info "$source"))
  local file_count=${info[0]}
  local total_size=${info[1]}

  if [[ "$file_count" -eq 0 ]] && [[ -d "$source" ]]; then
    echo "Warning: No files found in '$source'" >&2
    return 0
  fi

  echo "Source: $source"
  echo "Destination: $dest_path"
  echo "Files: $file_count"
  echo "Size: $(format_size "$total_size")"

  copy_with_rsync "$source" "$dest_path"

  if [[ $? -eq 0 ]]; then
    echo "✓ Successfully copied '$source'"
    return 0
  else
    echo "✗ Failed to copy '$source'" >&2
    return 1
  fi
}

show_final_summary() {
  local total_sources="$1"
  local failed_sources=("${@:2}")

  echo
  echo "========================================"
  echo "Copy operation completed!"
  echo "Processed: $total_sources source(s)"

  if [[ ${#failed_sources[@]} -eq 0 ]]; then
    echo "✓ All sources copied successfully"
    return 0
  else
    echo "✗ Failed to copy ${#failed_sources[@]} source(s):" >&2
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

  if [[ "$FORCE" = false ]]; then

    if [[ $total_sources -gt 20 ]]; then
      echo "About to copy $total_sources item(s)."
      echo "Too many items to list individually. First 10 items:"
      local count=0
      for source in "${SOURCES[@]}"; do
        count=$((count + 1))
        if [[ $count -le 10 ]]; then
          echo "  - $source"
        else
          echo "  ... and $((total_sources - 10)) more items"
          break
        fi
      done
    else
      echo "About to copy $total_sources item(s):"
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
    echo "Force mode: Copying $total_sources source(s) without confirmation..."
  fi

  echo "Starting copy operation with $total_sources source(s)..."

  for source in "${SOURCES[@]}"; do
    current=$((current + 1))
    echo
    echo "[$current/$total_sources] Processing: $source"
    echo "----------------------------------------"

    if ! process_source "$source"; then
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

