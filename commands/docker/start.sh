#!/bin/bash

d.start() {
  if [[ -z $1 ]]; then
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Start")] $(_c LIGHT_YELLOW "Usage: d.start <all / container>")"
    return
  fi

  if [[ $1 == "all" ]]; then
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Start")] $(_c LIGHT_GREEN "Starting all containers...")"
    docker container start $(docker ps -aq) >/dev/null 2>&1
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Start")] $(_c LIGHT_GREEN "All containers started")"
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

    __epx_echo "[$(_c LIGHT_BLUE "Docker - Start")] $container_text $(_c LIGHT_BLUE "$containers") $(_c LIGHT_GREEN "starting...")"
    docker container start "$@" >/dev/null 2>&1
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Start")] $container_text $(_c LIGHT_BLUE "$containers") $(_c LIGHT_GREEN "started")"
  fi
}

. "$EPX_PATH/commands/docker/_autocomplete.sh"
complete -F _d_autocomplete_all d.start
