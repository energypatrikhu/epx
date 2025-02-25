#!/bin/bash

d.attach() {
  if [[ -z $1 ]]; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Docker - Attach")] $(_c LIGHT_YELLOW "Usage: d.attach <container>")"
    return
  fi

  docker container attach "$@"
}

. "$EPX_PATH/commands/docker/_autocomplete.sh"
complete -F _d_autocomplete d.attach
