_cci docker

help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_YELLOW "Usage: d.pull [<options>] [container1, container2, ...]")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_YELLOW "Options:")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_YELLOW "  -a | --all") $(_c LIGHT_GREEN "Pull all containers defined in the config file")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_YELLOW "  -h | --help") $(_c LIGHT_GREEN "Show this help message")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_YELLOW "  [container1, container2, ...]") $(_c LIGHT_GREEN "Pull specific containers by name")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_YELLOW "  If no arguments are provided, it will pull the compose file in the current directory")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_YELLOW "  If the config file is not found, it is necessary to create one at ${EPX_HOME}/.config/docker.config")"
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

# if all option is provided, pull all containers defined in the config file
if [[ "${opt_all}" == "true" ]]; then
  if [[ ! -f "${EPX_HOME}/.config/docker.config" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_RED "Config file not found, please create one at ${EPX_HOME}/.config/docker.config")"
    help
    exit
  fi

  . "${EPX_HOME}/.config/docker.config"

  c_count=0
  c_amount=$(find "${CONTAINERS_DIR}" -mindepth 1 -maxdepth 1 -type d | wc -l)
  for d in "${CONTAINERS_DIR}"/*; do
    if [[ -d "${d}" ]]; then
      c_name=$(basename -- "${d}")
      c_count=$((c_count + 1))

      if [[ ! -f "${d}/docker-compose.yml" ]]; then
        echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_RED "[${c_count}/${c_amount}] docker-compose.yml not found in ${d}, skipping...")"
        continue
      fi

      echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_GREEN "[${c_count}/${c_amount}] Pulling compose file in ${d}...")"
      docker compose --file "${d}/docker-compose.yml" pull
      echo ""
    fi
  done
  exit
fi

# check if container name is provided
if [[ -n $* ]]; then
  if [[ ! -f "${EPX_HOME}/.config/docker.config" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_RED "Config file not found, please create one at ${EPX_HOME}/.config/docker.config")"
    help
    exit
  fi

  . "${EPX_HOME}/.config/docker.config"

  c_count=0
  c_amount=$#
  for c in "${@}"; do
    dirname="${CONTAINERS_DIR}/${c}"
    c_count=$((c_count + 1))

    if [[ ! -f "${dirname}/docker-compose.yml" ]]; then
      echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_RED "[${c_count}/${c_amount}] docker-compose.yml not found in ${dirname}, skipping...")"
      continue
    fi

    echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_GREEN "[${c_count}/${c_amount}] Pulling compose file in ${dirname}...")"
    docker compose --file "${dirname}/docker-compose.yml" pull
    echo ""
  done
  exit
fi

# if nothing is provided, just start compose file in current directory
if [[ ! -f "docker-compose.yml" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_RED "docker-compose.yml not found in current directory")"
  help
  exit
fi

echo -e "[$(_c LIGHT_BLUE "Docker - Pull")] $(_c LIGHT_GREEN "Pulling compose file in current directory...")"
docker compose --file docker-compose.yml pull
echo ""
