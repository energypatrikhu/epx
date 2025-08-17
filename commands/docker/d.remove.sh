_cci dockerif [[ -z "${1-}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Remove")] $(_c LIGHT_YELLOW "Usage: d.rm <all / container>")"
  exit
fi

if [[ "${1-}" == "all" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Remove")] $(_c LIGHT_RED "Removing all containers...")"
  docker rm -f $(docker ps -aq) >/dev/null 2>&1
  echo -e "[$(_c LIGHT_BLUE "Docker - Remove")] $(_c LIGHT_RED "All containers removed")"
else
  if [[ $# -eq 1 ]]; then
    container_text="Container"
  else
    container_text="Containers"
  fi
  containers=$(printf "%s, " "${@}" | sed 's/, $//')

  echo -e "[$(_c LIGHT_BLUE "Docker - Remove")] "${container_text}" $(_c LIGHT_BLUE "${containers}") $(_c LIGHT_RED "removing...")"
  docker rm -f "${@}" >/dev/null 2>&1
  echo -e "[$(_c LIGHT_BLUE "Docker - Remove")] "${container_text}" $(_c LIGHT_BLUE "${containers}") $(_c LIGHT_RED "removed")"
fi
