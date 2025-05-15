#!/bin/bash

d.inspect() {
  if [[ -z $1 ]]; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Docker - Inspect")] $(_c LIGHT_YELLOW "Usage: d.inspect <container>")"
    return
  fi

  docker inspect "$@"
}

. "$EPX_PATH/commands/docker/_autocomplete.sh"
complete -F _d_autocomplete d.inspect
complete -F _d_autocomplete d.i
