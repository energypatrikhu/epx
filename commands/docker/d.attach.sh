source "${EPX_HOME}/helpers/header.sh"

source "${EPX_HOME}/helpers/check-command-installed.sh"
_cci docker

source "${EPX_HOME}/helpers/colorize.sh"
source "${EPX_HOME}/helpers/colors.sh"

if [[ -z "${1}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Attach")] $(_c LIGHT_YELLOW "Usage: d.attach <container>")"
  exit 1
fi

docker container attach --sig-proxy=false --detach-keys="ctrl-c" "${@}"
