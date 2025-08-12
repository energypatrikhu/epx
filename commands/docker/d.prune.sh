source "${EPX_HOME}/helpers/header.sh"

source "${EPX_HOME}/helpers/check-command-installed.sh"
_cci docker

source "${EPX_HOME}/helpers/colorize.sh"
source "${EPX_HOME}/helpers/colors.sh"

if [[ -z "${1}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_YELLOW "Usage: d.prune <all / images / containers / volumes / networks> [options]")"
  exit
fi

case "${1}" in
all)
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_CYAN "Pruning all unused Docker resources...")"
  docker system prune --all --volumes "${@:2}"
  ;;
images)
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_CYAN "Pruning unused Docker images...")"
  docker image prune --all "${@:2}"
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
*)
  echo -e "[$(_c LIGHT_BLUE "Docker - Prune")] $(_c LIGHT_RED "Unknown option: "${1}"")"
  exit 1
  ;;
esac
