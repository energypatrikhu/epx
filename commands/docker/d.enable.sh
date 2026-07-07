_help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - Enable Update")] Usage: $(_c LIGHT_YELLOW "d.Enable")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Enable Update")] Remove ignore file to allow 'd.up --all' global updates"
  echo -e "[$(_c LIGHT_BLUE "Docker - Enable Update")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Enable Update")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Enable Update")]   -h, --help        Show this _help message and exit"
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
  echo -e "[$(_c LIGHT_BLUE "Docker - Enable Update")] $(_c LIGHT_RED "Config file not found, please create one at") ${EPX_HOME}/.config/docker.config"
  _help
  exit
fi

. "${EPX_HOME}/.config/docker.config"

container_name="${1:-}"

if [[ -n "${container_name}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Enable Update")] $(_c LIGHT_RED "Container name not provided!")"
  _help
  exit
fi

if [[ ! -f "${CONTAINERS_DIR}/${container_name}/.ignore-update" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Enable Update")] .ignore-update $(_c LIGHT_RED "does not exist!")"
  exit
fi

rm "${CONTAINERS_DIR}/${container_name}/.ignore-update"

echo "Removed .ignore-update from ${container_name}"
