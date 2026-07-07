_help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - Disable Update")] Usage: $(_c LIGHT_YELLOW "d.disable")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Disable Update")] Add ignore file to disable 'd.up --all' global updates"
  echo -e "[$(_c LIGHT_BLUE "Docker - Disable Update")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Disable Update")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Disable Update")]   -h, --help        Show this help message and exit"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

if [[ ! -f "${EPX_HOME}/.config/docker.config" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Disable Update")] $(_c LIGHT_RED "Config file not found, please create one at") ${EPX_HOME}/.config/docker.config"
  help
  exit
fi

. "${EPX_HOME}/.config/docker.config"

container_name="${1:-}"

if [[ -n "${container_name}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Disable Update")] $(_c LIGHT_RED "Container name not provided!")"
  help
  exit
fi

if [[ -f "${CONTAINERS_DIR}/${container_name}/.ignore-update" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Disable Update")] .ignore-update $(_c LIGHT_RED "already exist!")"
  exit
fi

touch "${CONTAINERS_DIR}/${container_name}/.ignore-update"

echo "Added .ignore-update to ${container_name}"
