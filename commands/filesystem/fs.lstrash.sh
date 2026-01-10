_help() {
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] Usage: $(_c LIGHT_YELLOW "fs.lstrash [trash-path]")"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] List contents of configured trash directories"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")]"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] Options:"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")]   -h, --help            Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")]"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")]   fs.lstrash"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")]   fs.lstrash /path/to/my_trash"
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

_cci_pkg ls:coreutils

trash_config="${EPX_HOME}/.config/trash.config"
specific_trash="${1-}"

if [[ ! -f "$trash_config" ]]; then
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] $(_c LIGHT_RED "Error"): Trash config not found at $trash_config" >&2
  exit 1
fi

TRASH_DIRS=$(grep -o 'TRASH_DIRS="[^"]*"' "$trash_config" | cut -d'"' -f2)

if [[ -z "$TRASH_DIRS" ]]; then
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] $(_c LIGHT_RED "Error"): TRASH_DIRS not defined in config" >&2
  exit 1
fi

_read_trash_dirs() {
  IFS=':' read -ra dirs <<< "$TRASH_DIRS"
  for dir in "${dirs[@]}"; do
    if [[ -n "$dir" ]]; then
      dir="${dir//\\/}"
      echo "$dir"
    fi
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



_list_trash_contents() {
  local trash_path="${1-}"

  if [[ ! -d "$trash_path" ]]; then
    echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] $(_c LIGHT_YELLOW "Warning"): Trash directory does not exist at $trash_path" >&2
    return 1
  fi

  local item_count=$(find "$trash_path" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l)

  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] $(_c LIGHT_CYAN "Trash: $trash_path")"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] Items: $(_c LIGHT_YELLOW "$item_count")"

  if [[ $item_count -gt 0 ]]; then
    echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] $(_c LIGHT_GREEN "Contents"):"
    find "$trash_path" -mindepth 1 -maxdepth 1 2>/dev/null | while read -r item; do
      local item_name=$(basename "$item")
      echo -e "[$(_c LIGHT_BLUE "FS - List Trash")]   - $item_name"
    done
  else
    echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] $(_c LIGHT_YELLOW "Empty")"
  fi
}

if [[ -n "$specific_trash" ]]; then
  if _is_valid_trash_dir "$specific_trash"; then
    _list_trash_contents "$specific_trash"
  else
    echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] $(_c LIGHT_RED "Error"): Trash directory '$specific_trash' is not a configured trash directory" >&2
    exit 1
  fi
else
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] Available trash directories:"
  echo ""

  all_dirs=$(_read_trash_dirs)

  if [[ -z "$all_dirs" ]]; then
    echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] $(_c LIGHT_YELLOW "Warning"): No trash directories configured"
    exit 1
  fi

  while IFS= read -r trash_path; do
    if [[ -d "$trash_path" ]]; then
      item_count=$(find "$trash_path" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l)
      echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] $(_c LIGHT_CYAN "$trash_path") - $(_c LIGHT_YELLOW "$item_count") items"
    else
      echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] $(_c LIGHT_YELLOW "$trash_path") - $(_c LIGHT_RED "does not exist")"
    fi
  done <<< "$all_dirs"

  echo ""
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] Use $(_c LIGHT_YELLOW "fs.lstrash <trash-path>") to view contents"
fi
