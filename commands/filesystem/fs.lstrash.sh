_help() {
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] Usage: $(_c LIGHT_YELLOW "fs.lstrash [trash-name|trash-path]")"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] List contents of configured trash directories"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")]"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] Options:"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")]   -h, --help            Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")]"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")]   fs.lstrash"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")]   fs.lstrash my_trash_name"
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

source "$trash_config"

if [[ -z "$TRASH_DIRS" ]]; then
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] $(_c LIGHT_RED "Error"): TRASH_DIRS not defined in config" >&2
  exit 1
fi

_read_trash_dirs() {
  IFS=':' read -ra dirs <<< "$TRASH_DIRS"
  for dir in "${dirs[@]}"; do
    [[ -n "$dir" ]] && echo "$dir"
  done
}

_get_trash_name() {
  local path="${1-}"
  basename "$path"
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

_find_trash_by_name() {
  local search_name="${1-}"
  IFS=':' read -ra dirs <<< "$TRASH_DIRS"
  for dir in "${dirs[@]}"; do
    if [[ -n "$dir" ]]; then
      local dir_name=$(basename "$dir")
      if [[ "$dir_name" == "$search_name" ]]; then
        echo "$dir"
        return 0
      fi
    fi
  done
  return 1
}

_list_trash_contents() {
  local trash_path="${1-}"
  local trash_name="${2-}"

  if [[ ! -d "$trash_path" ]]; then
    echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] $(_c LIGHT_YELLOW "Warning"): Trash directory '$trash_name' does not exist at $trash_path" >&2
    return 1
  fi

  local item_count=$(find "$trash_path" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l)

  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] $(_c LIGHT_CYAN "Trash: $trash_name")"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] Path: $(_c LIGHT_YELLOW "$trash_path")"
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] Items: $(_c LIGHT_YELLOW "$item_count")"

  if [[ $item_count -gt 0 ]]; then
    echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] $(_c LIGHT_GREEN "Contents:"): "
    find "$trash_path" -mindepth 1 -maxdepth 1 -printf '[$(_c LIGHT_BLUE "FS - List Trash")]   - %f\n' 2>/dev/null
  else
    echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] $(_c LIGHT_YELLOW "Empty")"
  fi
}

if [[ -n "$specific_trash" ]]; then
  if _is_valid_trash_dir "$specific_trash"; then
    trash_name=$(_get_trash_name "$specific_trash")
    _list_trash_contents "$specific_trash" "$trash_name"
  else
    trash_path=$(_find_trash_by_name "$specific_trash")

    if [[ -n "$trash_path" ]]; then
      _list_trash_contents "$trash_path" "$specific_trash"
    else
      echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] $(_c LIGHT_RED "Error"): Trash directory '$specific_trash' is not a configured trash directory" >&2
      exit 1
    fi
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
    trash_name=$(_get_trash_name "$trash_path")

    if [[ -d "$trash_path" ]]; then
      local item_count=$(find "$trash_path" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l)
      echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] $(_c LIGHT_CYAN "$trash_name") - $(_c LIGHT_YELLOW "$item_count") items"
    else
      echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] $(_c LIGHT_YELLOW "$trash_name") - $(_c LIGHT_RED "does not exist")"
    fi
  done <<< "$all_dirs"

  echo ""
  echo -e "[$(_c LIGHT_BLUE "FS - List Trash")] Use $(_c LIGHT_YELLOW "fs.lstrash <trash-name>") to view contents"
fi
