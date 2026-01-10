_get_trash_names() {
  local trash_config="${EPX_HOME}/.config/trash.config"

  if [[ -f "$trash_config" ]]; then
    . "$trash_config"

    if [[ -n "$TRASH_DIRS" ]]; then
      IFS=':' read -ra dirs <<< "$TRASH_DIRS"
      for dir in "${dirs[@]}"; do
        [[ -n "$dir" ]] && basename "$dir"
      done
    fi
  fi
}

local current_command="${COMP_WORDS[0]##*/}"

if [[ "$current_command" == "fs.cleartrash" ]]; then
  if [[ ${#COMP_WORDS[@]} -eq 2 ]]; then
    local trash_names=$(_get_trash_names)
    COMPREPLY=($(compgen -W "$trash_names -f --force" -- "${COMP_WORDS[1]}"))
  elif [[ ${#COMP_WORDS[@]} -eq 3 ]]; then
    if [[ "${COMP_WORDS[1]}" == "-f" ]] || [[ "${COMP_WORDS[1]}" == "--force" ]]; then
      local trash_names=$(_get_trash_names)
      COMPREPLY=($(compgen -W "$trash_names" -- "${COMP_WORDS[2]}"))
    fi
  fi
elif [[ "$current_command" == "fs.lstrash" ]]; then
  if [[ ${#COMP_WORDS[@]} -eq 2 ]]; then
    local trash_names=$(_get_trash_names)
    COMPREPLY=($(compgen -W "$trash_names" -- "${COMP_WORDS[1]}"))
  fi
fi
