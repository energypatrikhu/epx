#!/bin/bash

d.attach() {
  if [[ -z $1 ]]; then
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Attach")] $(_c LIGHT_YELLOW "Usage: d.attach <container>")"
    return
  fi

  docker container attach --sig-proxy=false --detach-keys="ctrl-c" "$@"
}

. "$EPX_HOME/commands/docker/_autocomplete.sh"
complete -F _d_autocomplete d.attach
