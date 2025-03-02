#!/bin/bash

d.shell() {
  if [[ -z $1 ]]; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Docker - Shell")] $(_c LIGHT_YELLOW "Usage: d.shell <container>")"
    return
  fi

  for shell in bash sh /bin/bash /bin/sh /usr/bin/bash /usr/bin/sh; do
    if docker exec -it "$1" "$shell" 2>/dev/null; then
      return
    fi
  done
  printf "%s\n" "[$(_c LIGHT_RED "Error")] $(_c LIGHT_YELLOW "No suitable shell found in container $1")"
}

. "$EPX_PATH/commands/docker/_autocomplete.sh"
complete -F _d_autocomplete d.shell
