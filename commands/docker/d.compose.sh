_help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - Compose")] Usage: $(_c LIGHT_YELLOW "d.compose [service name]")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Compose")] Create a docker-compose.yml file from a template"
  echo -e "[$(_c LIGHT_BLUE "Docker - Compose")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Compose")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Compose")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "Docker - Compose")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Compose")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Compose")]   d.compose my_service"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "Docker - Compose")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci docker

if [[ ! -f "${EPX_HOME}/.templates/docker/docker-compose.template" ]]; then
  echo -e "[$(_c LIGHT_RED "Docker - Compose")] $(_c LIGHT_YELLOW "Template for docker compose not found.")"
  exit
fi

if [[ -f docker-compose.yml ]]; then
  echo -e "[$(_c LIGHT_RED "Docker - Compose")] $(_c LIGHT_YELLOW "docker-compose.yml already exists. Please remove it before creating a new one.")"
  exit
fi

if ! cp -f "${EPX_HOME}/.templates/docker/docker-compose.template" docker-compose.yml >/dev/null 2>&1; then
  echo -e "[$(_c LIGHT_RED "Docker - Compose")] $(_c LIGHT_YELLOW "Failed to copy template for docker compose.")"
  exit
fi

if [[ -n "${1-}" ]]; then
  sed -i "s/CHANGE_ME/${1}/g" docker-compose.yml
fi

echo -e "[$(_c LIGHT_BLUE "Docker - Compose")] $(_c LIGHT_GREEN "Docker compose created.")"
