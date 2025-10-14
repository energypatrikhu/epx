_cci docker

if [[ -z "${1-}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_YELLOW "Usage: d.prune <all / images / containers / volumes / networks / build> [options]")"
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
