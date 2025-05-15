#!/bin/bash

d.stop() {
  if [[ -z $1 ]]; then
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Stop")] $(_c LIGHT_YELLOW "Usage: d.stop <all / container>")"
    return
  fi

  if [[ $1 == "all" ]]; then
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Stop")] $(_c LIGHT_RED "Stopping all containers...")"
    docker container stop $(docker ps -aq) >/dev/null 2>&1
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Stop")] $(_c LIGHT_RED "All containers stopped")"
  else
    if [ $# -eq 1 ]; then
      container_text="Container"
    else
      container_text="Containers"
    fi
    containers=$(printf "%s, " "$@" | sed 's/, $//')

    __epx_echo "[$(_c LIGHT_BLUE "Docker - Stop")] $container_text $(_c LIGHT_BLUE "$containers") $(_c LIGHT_RED "stopping...")"
    docker container stop "$@" >/dev/null 2>&1
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Stop")] $container_text $(_c LIGHT_BLUE "$containers") $(_c LIGHT_RED "stopped")"
  fi
}

. "$EPX_PATH/commands/docker/_autocomplete.sh"
complete -F _d_autocomplete_all d.stop
