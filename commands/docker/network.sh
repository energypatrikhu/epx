#!/bin/bash

d.net() {
  if [[ -z $1 ]]; then
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Network")] $(_c LIGHT_YELLOW "Usage: d.net <... options>")"
    return
  fi

  docker network "$@"
}

d.network() {
  d.net $@
}

. "$EPX_HOME/commands/docker/_autocomplete.sh"
complete -F _d_autocomplete d.net
complete -F _d_autocomplete d.network
