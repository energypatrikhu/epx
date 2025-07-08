#!/bin/bash

d.prune() {
  if [[ -z $1 ]]; then
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_YELLOW "Usage: d.prune <all / images / containers / volumes / networks> [options]")"
    return
  fi

  local args=("$@")

  case $1 in
  all)
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_CYAN "Pruning all unused Docker resources...")"
    docker system prune --all --volumes ${args[@]:1}
    ;;
  images)
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_CYAN "Pruning unused Docker images...")"
    docker image prune --all ${args[@]:1}
    ;;
  containers)
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_CYAN "Pruning stopped Docker containers...")"
    docker container prune ${args[@]:1}
    ;;
  volumes)
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_CYAN "Pruning unused Docker volumes...")"
    docker volume prune ${args[@]:1}
    ;;
  networks)
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_CYAN "Pruning unused Docker networks...")"
    docker network prune ${args[@]:1}
    ;;
  *)
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_RED "Unknown option: $1")"
    return 1
    ;;
  esac
}

. "$EPX_HOME/commands/docker/_autocomplete.sh"
complete -F _d_autocomplete_prune d.prune
