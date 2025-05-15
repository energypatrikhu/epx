#!/bin/bash

d.logs() {
  if [[ -z $1 ]]; then
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Logs")] $(_c LIGHT_YELLOW "Usage: d.logs <container> [--all | -a]")"
    return
  fi

  if [[ ! $2 = "--all" ]] && [[ ! $2 = "-a" ]]; then
    docker container logs -f "$1" --since "$(docker inspect "$1" | jq .[0].State.StartedAt | sed 's/\"//g')"
    return
  fi

  docker container logs -f "$@"
}
d.log() {
  d.logs $@
}

. "$EPX_PATH/commands/docker/_autocomplete.sh"
complete -F _d_autocomplete d.logs
complete -F _d_autocomplete d.log
