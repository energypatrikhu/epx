d.logs() {
  if [[ -z $1 ]]; then
    printf "[${EPX_COLORS["LIGHT_BLUE"]}Docker${EPX_COLORS["NC"]}] ${EPX_COLORS["LIGHT_YELLOW"]}Usage: d.logs <container>${EPX_COLORS["NC"]}\n"
    return
  fi

  docker container logs -f "$@"
}

. $EPX_PATH/commands/docker/_autocomplete.sh
complete -F _d_autocomplete d.logs
