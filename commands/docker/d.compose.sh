source "${EPX_HOME}/helpers/header.sh"

source "${EPX_HOME}/helpers/check-command-installed.sh"
_cci docker

source "${EPX_HOME}/helpers/colorize.sh"
source "${EPX_HOME}/helpers/colors.sh"

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Compose")] $(_c LIGHT_YELLOW "Usage: d.compose [service name]")"
  exit
fi

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
