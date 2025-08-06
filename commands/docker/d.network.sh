#!/bin/bash

source "${EPX_HOME}/helpers/check-command-installed.sh"
_cci docker

source "${EPX_HOME}/helpers/colorize.sh"
source "${EPX_HOME}/helpers/colors.sh"

if [[ -z "${1}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Network")] $(_c LIGHT_YELLOW "Usage: d.net <... options>")"
  exit
fi

docker network "${@}"
