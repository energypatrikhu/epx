#!/bin/bash

d.logs() {
  if [[ -z $1 ]]; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Docker - Logs")] $(_c LIGHT_YELLOW "Usage: d.logs <container>")"
    return
  fi

  docker container logs -f "$@" --since "$(docker inspect "$@" | jq .[0].State.StartedAt | sed 's/\"//g')"
}

. "$EPX_PATH/commands/docker/_autocomplete.sh"
complete -F _d_autocomplete d.logs
