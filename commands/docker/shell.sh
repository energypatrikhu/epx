d.shell() {
  if [[ -z $1 ]]; then
    printf "[${EPX_COLORS["LIGHT_BLUE"]}Docker - Shell${EPX_COLORS["NC"]}] ${EPX_COLORS["LIGHT_YELLOW"]}Usage: d.shell <container>${EPX_COLORS["NC"]}\n"
    return
  fi

  docker exec -it "$1" /bin/bash
}

. $EPX_PATH/commands/docker/_autocomplete.sh
complete -F _d_autocomplete d.shell
