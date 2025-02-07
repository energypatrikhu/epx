d.shell() {
  if [[ -z $1 ]]; then
    printf "[$(_c LIGHT_BLUE "Docker - Shell")] $(_c LIGHT_YELLOW "Usage: d.shell <container>")\n"
    return
  fi

  docker exec -it "$1" /bin/bash
}

. $EPX_PATH/commands/docker/_autocomplete.sh
complete -F _d_autocomplete d.shell
