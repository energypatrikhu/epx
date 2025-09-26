_cci docker

help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_YELLOW "Usage: d.up [<options>] [container1, container2, ...]")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_YELLOW "Options:")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_YELLOW "  -a | --all") $(_c LIGHT_GREEN "Start all containers defined in the config file")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_YELLOW "  -h | --help") $(_c LIGHT_GREEN "Show this help message")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_YELLOW "  [container1, container2, ...]") $(_c LIGHT_GREEN "Start specific containers by name")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_YELLOW "  If no arguments are provided, it will start the compose file in the current directory")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_YELLOW "  If the config file is not found, it is necessary to create one at ${EPX_HOME}/.config/docker.config")"
}

opt_help=false
opt_all=false

for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    elif [[ "${arg}" =~ ^-*a(ll)?$ ]]; then
      opt_all=true
    else
      echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_RED "Unknown option: ${arg}")"
      help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  help
  exit
fi

if [[ "${opt_all}" == "true" ]]; then
  if [[ ! -f "${EPX_HOME}/.config/docker.config" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_RED "Config file not found, please create one at ${EPX_HOME}/.config/docker.config")"
    help
    exit
  fi

  . "${EPX_HOME}/.config/docker.config"

  for d in "${CONTAINERS_DIR}"/*; do
    if [[ -d "${d}" ]]; then
      if [[ -f "${d}/docker-compose.yml" ]]; then
        d.up "$(basename -- "${d}")"
      fi
    fi
  done
  exit
fi

# check if container name is provided
if [[ -n $* ]]; then
  if [[ ! -f "${EPX_HOME}/.config/docker.config" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_RED "Config file not found, please create one at ${EPX_HOME}/.config/docker.config")"
    help
    exit
  fi

  . "${EPX_HOME}/.config/docker.config"

  for c in "${@}"; do
    dirname="${CONTAINERS_DIR}/${c}"

    if [[ ! -f "${dirname}/docker-compose.yml" ]]; then
      echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_RED "docker-compose.yml not found in ${dirname}")"
      exit
    fi

    docker compose --file "${dirname}/docker-compose.yml" up --pull always --build --no-start # build if there are changes
    docker compose --file "${dirname}/docker-compose.yml" up --pull never --detach --no-build # start the container
    echo -e ""
  done
  exit
fi

# if nothing is provided, just start compose file in current directory
if [[ ! -f "docker-compose.yml" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_RED "docker-compose.yml not found in current directory")"
  help
  exit
fi

fbasename=$(basename -- "$(pwd)")

docker compose --file docker-compose.yml up --pull always --build --no-start # build if there are changes
docker compose --file docker-compose.yml up --pull never --detach --no-build # start the container
echo -e ""
