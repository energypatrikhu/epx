_help() {
  echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] Usage: $(_c LIGHT_YELLOW "fs.cleartrash [trash-path] [-f|--force]")"
  echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] Clear files from configured trash directories"
  echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")]"
  echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] Options:"
  echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")]   -h, --help            Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")]   -f, --force           Clear trash without confirmation"
  echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")]"
  echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")]   fs.cleartrash"
  echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")]   fs.cleartrash /path/to/my_trash -f"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg rm:coreutils

trash_config="${EPX_HOME}/.config/trash.config"
force=false
specific_trash=""

while [[ $# -gt 0 ]]; do
  case "${1-}" in
    -f|--force)
      force=true
      shift
      ;;
    -*)
      echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] $(_c LIGHT_RED "Error"): Unknown option '${1-}'"
      exit 1
      ;;
    *)
      specific_trash="${1-}"
      shift
      ;;
  esac
done

if [[ ! -f "$trash_config" ]]; then
  echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] $(_c LIGHT_RED "Error"): Trash config not found at $trash_config"
  exit 1
fi

. "$trash_config"

if [[ -z "$TRASH_DIRS" ]]; then
  echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] $(_c LIGHT_RED "Error"): TRASH_DIRS not defined in config"
  exit 1
fi

_read_trash_dirs() {
  IFS=':' read -ra dirs <<< "$TRASH_DIRS"
  for dir in "${dirs[@]}"; do
    [[ -n "$dir" ]] && echo "$dir"
  done
}


_is_valid_trash_dir() {
  local search_path="${1-}"
  IFS=':' read -ra dirs <<< "$TRASH_DIRS"
  for dir in "${dirs[@]}"; do
    if [[ "$dir" == "$search_path" ]]; then
      return 0
    fi
  done
  return 1
}


_clear_trash_dir() {
  local trash_path="${1-}"

  if [[ ! -d "$trash_path" ]]; then
    echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] $(_c LIGHT_YELLOW "Warning"): Trash directory not found at $trash_path"
    return 1
  fi

  local item_count=$(find "$trash_path" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l)

  if [[ $item_count -eq 0 ]]; then
    echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] Trash at $(_c LIGHT_YELLOW "$trash_path") is already empty"
    return 0
  fi

  echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] $(_c LIGHT_CYAN "Trash: $trash_path")"
  echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] Items: $(_c LIGHT_YELLOW "$item_count")"

  echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] Contents:"
  find "$trash_path" -mindepth 1 -maxdepth 1 2>/dev/null | while read -r item; do
    local item_name=$(basename "$item")
    echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")]   - $item_name"
  done

  if [[ "$force" == true ]]; then
    echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] Clearing without confirmation (force mode)..."
    rm -rf "${trash_path:?}"/*

    if [[ $? -eq 0 ]]; then
      echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] $(_c LIGHT_GREEN "Trash cleared successfully")"
      return 0
    else
      echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] $(_c LIGHT_RED "Error"): Failed to clear trash"
      return 1
    fi
  else
    read -p "$(echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] Clear this trash? $(_c LIGHT_YELLOW "[y/N]"): ")" -r response
    echo ""

    if [[ "$response" =~ ^[Yy]$ ]]; then
      rm -rf "${trash_path:?}"/*

      if [[ $? -eq 0 ]]; then
        echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] $(_c LIGHT_GREEN "Trash cleared successfully")"
        return 0
      else
        echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] $(_c LIGHT_RED "Error"): Failed to clear trash"
        return 1
      fi
    else
      echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] Skipped trash at $(_c LIGHT_YELLOW "$trash_path")"
      return 0
    fi
  fi
}

if [[ -n "$specific_trash" ]]; then
  if _is_valid_trash_dir "$specific_trash"; then
    _clear_trash_dir "$specific_trash"
  else
    echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] $(_c LIGHT_RED "Error"): Trash directory '$specific_trash' is not a configured trash directory"
    exit 1
  fi
else
  echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] Scanning trash directories..."
  echo ""

  all_dirs=$(_read_trash_dirs)

  if [[ -z "$all_dirs" ]]; then
    echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] $(_c LIGHT_YELLOW "Warning"): No trash directories configured"
    exit 1
  fi

  while IFS= read -r trash_path; do
    if [[ -n "$trash_path" ]]; then
      _clear_trash_dir "$trash_path"
      echo ""
    fi
  done <<< "$all_dirs"

  echo -e "[$(_c LIGHT_BLUE "FS - Clear Trash")] $(_c LIGHT_GREEN "Trash cleanup complete")"
fi
