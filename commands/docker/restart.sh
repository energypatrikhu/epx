#!/bin/bash

d.restart() {
  if [[ -z $1 ]]; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Docker - Restart")] $(_c LIGHT_YELLOW "Usage: d.restart <all / container>")"
    return
  fi

  if [[ $1 == "all" ]]; then
    docker container restart "$(docker container ls -a -q)" >/dev/null 2>&1
    printf "%s\n" "[$(_c LIGHT_BLUE "Docker - Restart")] $(_c LIGHT_CYAN "All containers restarted")"
  else
    printf "[%s] %s\n" "$(_c LIGHT_BLUE "Docker - Restart")" "$container_text $(_c LIGHT_BLUE "$containers") $(_c LIGHT_CYAN "restarting...")"

    docker container restart "$@" >/dev/null 2>&1

    if [ $# -eq 1 ]; then
      container_text="Container"
    else
      container_text="Containers"
    fi
    containers=$(printf "%s, " "$@" | sed 's/, $//')
    printf "[%s] %s\n" "$(_c LIGHT_BLUE "Docker - Restart")" "$container_text $(_c LIGHT_BLUE "$containers") $(_c LIGHT_CYAN "restarted")"
  fi
}

. $EPX_PATH/commands/docker/_autocomplete.sh
complete -F _d_autocomplete_all d.restart
