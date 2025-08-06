#!/bin/bash

source "${EPX_HOME}/helpers/check-command-installed.sh"
_cci docker

source "${EPX_HOME}/helpers/colorize.sh"
source "${EPX_HOME}/helpers/colors.sh"

if [[ -z "${1}" ]]; then
  echo -e "[$(_c LIGHT_BLUE 'Docker - Stop')] $(_c LIGHT_YELLOW "Usage: d.stop <all / container>")"
  exit
fi

if [[ "${1}" == "all" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Stop")] $(_c LIGHT_RED "Stopping all containers...")"
  docker container stop $(docker ps -aq) >/dev/null 2>&1
  echo -e "[$(_c LIGHT_BLUE "Docker - Stop")] $(_c LIGHT_RED "All containers stopped")"
else
  if [ $# -eq 1 ]; then
    container_text="Container"
  else
    container_text="Containers"
  fi

  read -ra arr <<<$*
  containers=""
  for i in "${arr[@]}"; do
    i=$(echo "${i}" | xargs) # trim spaces
    if [[ -n "${containers}" ]]; then
      containers+=", "
    fi
    containers+="$(_c LIGHT_BLUE "${i}")"
  done

  echo -e "[$(_c LIGHT_BLUE "Docker - Stop")] ${container_text} $(_c LIGHT_BLUE "${containers}") $(_c LIGHT_RED "stopping...")"
  docker container stop "${@}" >/dev/null 2>&1
  echo -e "[$(_c LIGHT_BLUE "Docker - Stop")] ${container_text} $(_c LIGHT_BLUE "${containers}") $(_c LIGHT_RED "stopped")"
fi
