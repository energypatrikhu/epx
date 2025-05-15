#!/bin/bash

d.exec() {
  if [[ -z $1 ]]; then
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Exec")] $(_c LIGHT_YELLOW "Usage: d.exec <container> <command> [args]")"
    return
  fi

  docker exec -it "$1" "${@:2}"
}

. "$EPX_PATH/commands/docker/_autocomplete.sh"
complete -F _d_autocomplete d.exec
