_cci rm

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
      echo -e "[$(_c LIGHT_BLUE "Clear Trash")] $(_c LIGHT_RED "Error"): Unknown option '${1-}'"
      exit 1
      ;;
    *)
      specific_trash="${1-}"
      shift
      ;;
  esac
done

if [[ ! -f "$trash_config" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Clear Trash")] $(_c LIGHT_RED "Error"): Trash config not found at $trash_config"
  exit 1
fi

source "$trash_config"

if [[ -z "$TRASH_DIRS" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Clear Trash")] $(_c LIGHT_RED "Error"): TRASH_DIRS not defined in config"
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

_clear_trash_dir() {
  local trash_name="${1-}"
  local trash_path="${2-}"

  if [[ ! -d "$trash_path" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Clear Trash")] $(_c LIGHT_YELLOW "Warning"): Trash directory '$trash_name' not found at $trash_path"
    return 1
  fi

  local item_count=$(find "$trash_path" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l)

  if [[ $item_count -eq 0 ]]; then
    echo -e "[$(_c LIGHT_BLUE "Clear Trash")] Trash '$(_c LIGHT_YELLOW "$trash_name")' is already empty"
    return 0
  fi

  echo -e "[$(_c LIGHT_BLUE "Clear Trash")] $(_c LIGHT_CYAN "Trash: $trash_name")"
  echo -e "[$(_c LIGHT_BLUE "Clear Trash")] Path: $(_c LIGHT_YELLOW "$trash_path")"
  echo -e "[$(_c LIGHT_BLUE "Clear Trash")] Items: $(_c LIGHT_YELLOW "$item_count")"

  echo -e "[$(_c LIGHT_BLUE "Clear Trash")] Contents:"
  find "$trash_path" -mindepth 1 -maxdepth 1 2>/dev/null | while read -r item; do
    local item_name=$(basename "$item")
    echo -e "[$(_c LIGHT_BLUE "Clear Trash")]   - $item_name"
  done

  if [[ "$force" == true ]]; then
    echo -e "[$(_c LIGHT_BLUE "Clear Trash")] Clearing without confirmation (force mode)..."
    rm -rf "${trash_path:?}"/*

    if [[ $? -eq 0 ]]; then
      echo -e "[$(_c LIGHT_BLUE "Clear Trash")] $(_c LIGHT_GREEN "Trash '$trash_name' cleared successfully")"
      return 0
    else
      echo -e "[$(_c LIGHT_BLUE "Clear Trash")] $(_c LIGHT_RED "Error"): Failed to clear trash '$trash_name'"
      return 1
    fi
  else
    read -p "$(echo -e "[$(_c LIGHT_BLUE "Clear Trash")] Clear this trash? $(_c LIGHT_YELLOW "[y/N]"): ")" -r response
    echo ""

    if [[ "$response" =~ ^[Yy]$ ]]; then
      rm -rf "${trash_path:?}"/*

      if [[ $? -eq 0 ]]; then
        echo -e "[$(_c LIGHT_BLUE "Clear Trash")] $(_c LIGHT_GREEN "Trash '$trash_name' cleared successfully")"
        return 0
      else
        echo -e "[$(_c LIGHT_BLUE "Clear Trash")] $(_c LIGHT_RED "Error"): Failed to clear trash '$trash_name'"
        return 1
      fi
    else
      echo -e "[$(_c LIGHT_BLUE "Clear Trash")] Skipped trash '$(_c LIGHT_YELLOW "$trash_name")'"
      return 0
    fi
  fi
}

if [[ -n "$specific_trash" ]]; then
  if _is_valid_trash_dir "$specific_trash"; then
    trash_path="$specific_trash"
    trash_name=$(_get_trash_name "$trash_path")
  else
    trash_path=$(_find_trash_by_name "$specific_trash")

    if [[ -z "$trash_path" ]]; then
      echo -e "[$(_c LIGHT_BLUE "Clear Trash")] $(_c LIGHT_RED "Error"): Trash directory '$specific_trash' is not a configured trash directory"
      exit 1
    fi
    trash_name="$specific_trash"
  fi

  _clear_trash_dir "$trash_name" "$trash_path"
else
  echo -e "[$(_c LIGHT_BLUE "Clear Trash")] Scanning trash directories..."
  echo ""

  all_dirs=$(_read_trash_dirs)

  if [[ -z "$all_dirs" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Clear Trash")] $(_c LIGHT_YELLOW "Warning"): No trash directories configured"
    exit 1
  fi

  while IFS= read -r trash_path; do
    trash_name=$(_get_trash_name "$trash_path")

    if [[ -n "$trash_path" ]]; then
      _clear_trash_dir "$trash_name" "$trash_path"
      echo ""
    fi
  done <<< "$all_dirs"

  echo -e "[$(_c LIGHT_BLUE "Clear Trash")] $(_c LIGHT_GREEN "Trash cleanup complete")"
fi
