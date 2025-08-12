source "${EPX_HOME}/helpers/header.sh"

source "${EPX_HOME}/helpers/check-command-installed.sh"
_cci pv find du

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
      if [[ ${#SOURCES[@]} -eq 0 ]] || [[ -z "$DESTINATION" ]]; then
        if [[ -z "$DESTINATION" ]] && [[ ${#SOURCES[@]} -gt 0 ]]; then
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

if [[ -z "$DESTINATION" ]]; then
  echo "Error: No destination specified" >&2
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
    stat -c%s "$target" 2>/dev/null || echo 0
  elif [[ -d "$target" ]]; then
    du -sb "$target" 2>/dev/null | cut -f1 || echo 0
  else
    echo 0
  fi
}

format_size() {
  local size="$1"

  if [[ "$size" -gt 0 ]]; then
    numfmt --to=iec-i --suffix=B "$size" 2>/dev/null || echo "${size} bytes"
  else
    echo "0 bytes"
  fi
}

should_overwrite() {
  local source="$1"
  local dest="$2"

  if [[ ! -e "$dest" ]]; then
    return 0
  fi

  return 0
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

build_cp_options() {
  local options=""

  [[ "$FORCE" = true ]] && options="$options -f"
  [[ "$DEREFERENCE" = true ]] && options="$options -L"
  [[ -n "$PRESERVE" ]] && options="$options --preserve=$PRESERVE"

  echo "$options"
}

copy_file() {
  local source_file="$1"
  local dest_file="$2"

  if pv "$source_file" > "$dest_file"; then
    rm "$source_file"
  else
    echo "Error: Failed to copy '$source_file'" >&2
    return 1
  fi
}

copy_directory() {
  local source="$1"
  local dest="$2"
  local file_count="$3"

  local current_file=0
  local source_len=${#source}

  mkdir -p "$dest"

  if [[ "$PRESERVE" != "" ]]; then
    find "$source" -type d -print0 | while IFS= read -r -d '' dir; do
      local relative_path="${dir:$source_len}"
      relative_path="${relative_path#/}"
      if [[ -n "$relative_path" ]]; then
        local dest_dir="$dest/$relative_path"
        mkdir -p "$dest_dir"
      fi
    done
  fi

  find "$source" -type f -print0 | while IFS= read -r -d '' file; do
    current_file=$((current_file + 1))
    local relative_path="${file:$source_len}"
    relative_path="${relative_path#/}"
    local dest_file="$dest/$relative_path"
    local dest_file_dir=$(dirname "$dest_file")

    mkdir -p "$dest_file_dir"

    if should_overwrite "$file" "$dest_file"; then
      echo "  [$current_file/$file_count] Copying: $relative_path"
      local file_size=$(stat -c%s "$file" 2>/dev/null || echo 0)
      copy_file "$file" "$dest_file"
    fi
  done
}

get_destination_path() {
  local source="$1"
  local dest="$2"

  if [[ -d "$dest" ]]; then
    echo "$dest/$(basename "$source")"
  else
    echo "$dest"
  fi
}

validate_source() {
  local source="$1"

  if [[ ! -e "$source" ]]; then
    echo "Error: '$source' does not exist" >&2
    return 1
  fi

  return 0
}

perform_copy_operation() {
  local source="$1"
  local dest_path="$2"

  echo "Analyzing '$source'..."
  local file_count=$(count_files "$source")
  local total_size=$(get_total_size "$source")

  if [[ "$file_count" -eq 0 ]] && [[ -d "$source" ]]; then
    echo "Warning: No files found in '$source'" >&2
    return 0
  fi

  echo "Source: $source"
  echo "Destination: $dest_path"
  echo "Files to copy: $file_count"
  echo "Total size: $(format_size "$total_size")"

  if [[ -f "$source" ]]; then

    if should_overwrite "$source" "$dest_path"; then
      echo "Copying file: $source -> $dest_path"
      copy_file "$source" "$dest_path"
      echo "✓ Successfully copied file"
    fi

  elif [[ -d "$source" ]]; then

    echo "Copying directory: $source -> $dest_path"
    copy_directory "$source" "$dest_path" "$file_count"
    echo "✓ Successfully copied directory"
  fi
}

copy_with_progress() {
  local source="$1"

  if ! validate_source "$source"; then
    return 1
  fi

  local dest_path=$(get_destination_path "$source" "$DESTINATION")

  perform_copy_operation "$source" "$dest_path"
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

    if ! copy_with_progress "$source"; then
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

