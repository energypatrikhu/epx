_help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - Shell")] Usage: $(_c LIGHT_YELLOW "d.shell <container>")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Shell")] Open an interactive shell session inside a specified Docker container"
  echo -e "[$(_c LIGHT_BLUE "Docker - Shell")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Shell")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Shell")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "Docker - Shell")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Shell")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Shell")]   d.shell my_container"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "Docker - Shell")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg docker:docker-ce-cli

if [[ -z "${1-}" ]]; then
  _help
  exit
fi

for shell in bash sh; do
  if docker exec -it ${1-} "${shell}" 2>/dev/null; then
    exit
  fi
done
echo -e "[$(_c LIGHT_BLUE "Docker - Shell")] $(_c LIGHT_RED "Error:") $(_c LIGHT_YELLOW "No suitable shell found in container ${1}")"
