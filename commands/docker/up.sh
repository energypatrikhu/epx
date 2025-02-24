#!/bin/bash

d.up() {
  if [[ $1 = "--help" ]] || [[ $1 = "-h" ]]; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_YELLOW "Usage: d.up [all / container]")"
    return
  fi

  if [ "$1" = "all" ]; then
    if [[ ! -f "$EPX_PATH/.config/d.up.config" ]]; then
      printf "%s\n" "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_RED "Config file not found, please create one at $EPX_PATH/.config/d.up.config")"
      return
    fi

    . "$EPX_PATH/.config/d.up.config"

    for d in "$CONTAINERS_DIR"/*; do
      if [ -d "$d" ]; then
        if [[ -f "$d/docker-compose.yml" ]]; then
          d.up "$(basename -- "$d")"
        fi
      fi
    done
    return
  fi

  # check if container name is provided
  if [[ -n $1 ]]; then
    if [[ ! -f "$EPX_PATH/.config/d.up.config" ]]; then
      printf "%s\n" "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_RED "Config file not found, please create one at $EPX_PATH/.config/d.up.config")"
      return
    fi

    . "$EPX_PATH/.config/d.up.config"

    fbasename=$(basename -- "$1")
    dirname="$CONTAINERS_DIR/$fbasename"

    if [[ ! -f "$dirname/docker-compose.yml" ]]; then
      printf "%s\n" "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_RED "docker-compose.yml not found in $dirname")"
      return
    fi

    docker compose -f "$dirname/docker-compose.yml" pull
    printf "\n"

    docker compose -p "$fbasename" -f "$dirname/docker-compose.yml" up -d
    printf "\n"
    return
  fi

  # if nothing is provided, just start compose file in current directory
  if [[ ! -f "docker-compose.yml" ]]; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_RED "docker-compose.yml not found in current directory")"
    return
  fi

  docker compose -f docker-compose.yml pull
  printf "\n"

  fbasename=$(basename -- "$(pwd)")

  docker compose -p "$fbasename" -f docker-compose.yml up -d
  printf "\n"
}

if [[ -f "$EPX_PATH/.config/d.up.config" ]]; then
  _d.up_autocomplete() {
    . "$EPX_PATH/.config/d.up.config"
    . "$EPX_PATH/commands/docker/_autocomplete.sh"

    container_dirs=()
    for d in "$CONTAINERS_DIR"/*; do
      if [ -d "$d" ]; then
        if [[ -f "$d/docker-compose.yml" ]]; then
          container_dirs+=("$(basename -- "$d")")
        fi
      fi
    done

    _autocomplete "${container_dirs[@]}"
  }
  complete -F _d.up_autocomplete d.up
fi
