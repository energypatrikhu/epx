#!/bin/bash

d.restart() {
  if [[ -z $1 ]]; then
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Restart")] $(_c LIGHT_YELLOW "Usage: d.restart <all / container>")"
    return
  fi

  if [[ $1 == "all" ]]; then
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Restart")] $(_c LIGHT_CYAN "Restarting all containers...")"
    docker container restart $(docker ps -aq) >/dev/null 2>&1
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Restart")] $(_c LIGHT_CYAN "All containers restarted")"
  else
    if [ $# -eq 1 ]; then
      container_text="Container"
    else
      container_text="Containers"
    fi

    read -ra arr <<<"$*"
    containers=""
    for i in "${arr[@]}"; do
      i=$(echo "$i" | xargs) # trim spaces
      if [[ -n $containers ]]; then
        containers+=", "
      fi
      containers+="$(_c LIGHT_BLUE "$i")"
    done

    __epx_echo "[$(_c LIGHT_BLUE "Docker - Restart")] $container_text $containers $(_c LIGHT_CYAN "restarting...")"
    docker container restart "$@" >/dev/null 2>&1
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Restart")] $container_text $containers $(_c LIGHT_CYAN "restarted")"
  fi
}

. "$EPX_HOME/commands/docker/_autocomplete.sh"
complete -F _d_autocomplete_all d.restart
