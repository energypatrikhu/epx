source "${EPX_HOME}/helpers/header.sh"

source "${EPX_HOME}/helpers/check-command-installed.sh"
_cci ufw

source "${EPX_HOME}/helpers/colorize.sh"
source "${EPX_HOME}/helpers/colors.sh"

if [[ -z "${1-}" ]]; then
  echo -e "[$(_c LIGHT_CYAN "UFW")] $(_c LIGHT_YELLOW "Usage: ufw.add <port>")"
  exit 1
fi

if [[ "${1-}" =~ ^[0-9]+$ ]]; then
  ufw allow "${1-}"
  exit
fi

echo -e "[$(_c LIGHT_CYAN "UFW")] $(_c LIGHT_RED "Error:") $(_c LIGHT_YELLOW "Invalid argument: ${1}")"
