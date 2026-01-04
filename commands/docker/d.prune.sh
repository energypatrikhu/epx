_help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")] Usage: $(_c LIGHT_YELLOW "d.prune <all / images / containers / volumes / networks / build> [options]")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")] Prune unused Docker resources"
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")]   d.prune all --force"
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")]   d.prune images"
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")]   d.prune containers"
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")]   d.prune volumes"
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")]   d.prune networks"
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")]   d.prune build --all"
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

_cci_pkg docker:docker-ce-cli

if [[ -z "${1-}" ]]; then
  _help
  exit
fi

case "${1-}" in
all)
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_CYAN "Pruning all unused Docker resources...")"
  docker system prune --volumes "${@:2}"
  ;;
images)
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_CYAN "Pruning unused Docker images...")"
  docker image prune "${@:2}"
  ;;
containers)
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_CYAN "Pruning stopped Docker containers...")"
  docker container prune "${@:2}"
  ;;
volumes)
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_CYAN "Pruning unused Docker volumes...")"
  docker volume prune "${@:2}"
  ;;
networks)
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_CYAN "Pruning unused Docker networks...")"
  docker network prune "${@:2}"
  ;;
build)
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_CYAN "Pruning unused Docker builder cache...")"
  docker buildx prune "${@:2}"
  ;;
*)
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_RED "Unknown option:") ${1-}"
  exit 1
  ;;
esac
