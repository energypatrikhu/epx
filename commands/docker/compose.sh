#!/bin/bash

d.compose() {
  if [[ -z $1 ]]; then
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Compose")] $(_c LIGHT_YELLOW "Usage: d.compose [service name]")"
    return
  fi

  local service_name="$1"

  if [[ ! -f "$EPX_PATH/.templates/docker/docker-compose.template" ]]; then
    __epx_echo "[$(_c LIGHT_RED "Docker - Compose")] $(_c LIGHT_YELLOW "Template for docker compose not found.")"
    return
  fi

  if [[ -f docker-compose.yml ]]; then
    __epx_echo "[$(_c LIGHT_RED "Docker - Compose")] $(_c LIGHT_YELLOW "docker-compose.yml already exists. Please remove it before creating a new one.")"
    return
  fi

  if ! cp -f "$EPX_PATH/.templates/docker/docker-compose.template" docker-compose.yml >/dev/null 2>&1; then
    __epx_echo "[$(_c LIGHT_RED "Docker - Compose")] $(_c LIGHT_YELLOW "Failed to copy template for docker compose.")"
    return
  fi

  if [[ -n $service_name ]]; then
    sed -i "s/CHANGE_ME/$service_name/g" docker-compose.yml
  fi

  __epx_echo "[$(_c LIGHT_BLUE "Docker - Compose")] $(_c LIGHT_GREEN "Docker compose created.")"
}
