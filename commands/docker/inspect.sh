#!/bin/bash

d.inspect() {
  if [[ -z $1 ]]; then
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Inspect")] $(_c LIGHT_YELLOW "Usage: d.inspect <container>")"
    return
  fi

  docker inspect "$@"
}

d.i() {
  d.inspect $@
}

. "$EPX_HOME/commands/docker/_autocomplete.sh"
complete -F _d_autocomplete d.inspect
complete -F _d_autocomplete d.i
