_cci docker

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_YELLOW "Usage: d.pull [<options>] [all / [container1, container2, ...]]")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_YELLOW "Options:")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_YELLOW "  all") $(_c LIGHT_GREEN "Pull all containers defined in the config file")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_YELLOW "  [container1, container2, ...]") $(_c LIGHT_GREEN "Pull specific containers by name")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_YELLOW "  If no arguments are provided, it will pull the compose file in the current directory")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_YELLOW "  If the config file is not found, it will prompt to create one at ${EPX_HOME}/.config/docker.config")"
  exit
fi

if [[ "${1-}" = "all" ]]; then
  if [[ ! -f "${EPX_HOME}/.config/docker.config" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_RED "Config file not found, please create one at ${EPX_HOME}/.config/docker.config")"
    echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_RED "Use 'd.pull --help' for more information")"
    exit
  fi

  . "${EPX_HOME}/.config/docker.config"

  for d in "${CONTAINERS_DIR}"/*; do
    if [[ -d "${d}" ]]; then
      if [[ -f "${d}/docker-compose.yml" ]]; then
        d.pull "$(basename -- "${d}")"
      fi
    fi
  done
  exit
fi

# check if container name is provided
if [[ -n $* ]]; then
  if [[ ! -f "${EPX_HOME}/.config/docker.config" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_RED "Config file not found, please create one at ${EPX_HOME}/.config/docker.config")"
    echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_RED "Use 'd.pull --help' for more information")"
    exit
  fi

  . "${EPX_HOME}/.config/docker.config"

  for c in "${@}"; do
    dirname="${CONTAINERS_DIR}/${c}"

    if [[ ! -f "${dirname}/docker-compose.yml" ]]; then
      echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_RED "docker-compose.yml not found in ${dirname}")"
      exit
    fi

    docker compose -f "${dirname}/docker-compose.yml" pull
    echo -e ""
  done
  exit
fi

# if nothing is provided, just start compose file in current directory
if [[ ! -f "docker-compose.yml" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_RED "docker-compose.yml not found in current directory")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_RED "Use 'd.pull --help' for more information")"
  exit
fi

fbasename=$(basename -- "$(pwd)")

docker compose -f docker-compose.yml pull
echo -e ""
