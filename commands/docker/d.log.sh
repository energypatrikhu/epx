source "${EPX_HOME}/helpers/header.sh"

source "${EPX_HOME}/helpers/check-command-installed.sh"
_cci docker

source "${EPX_HOME}/helpers/colorize.sh"
source "${EPX_HOME}/helpers/colors.sh"

if [[ -z "${1}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Logs")] $(_c LIGHT_YELLOW "Usage: d.logs <container> [--all | -a]")"
  exit
fi

if [[ ! "${2}" = "--all" ]] && [[ ! "${2}" = "-a" ]]; then
  docker container logs -f "${1}" --since "$(docker inspect "${1}" | jq .[0].State.StartedAt | sed 's/\"//g')"
  exit
fi

docker container logs -f "${@}"
