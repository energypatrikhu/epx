_help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - Restart")] Usage: $(_c LIGHT_YELLOW "d.restart <all / container>")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Restart")] Restart one or more Docker containers or all containers"
  echo -e "[$(_c LIGHT_BLUE "Docker - Restart")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Restart")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Restart")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "Docker - Restart")]   -a, --all         Restart all containers"
  echo -e "[$(_c LIGHT_BLUE "Docker - Restart")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Restart")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Restart")]   d.restart --all"
  echo -e "[$(_c LIGHT_BLUE "Docker - Restart")]   d.restart my_container"
}

opt_help=false
opt_all=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    elif [[ "${arg}" =~ ^-*a(ll)?$ ]]; then
      opt_all=true
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg docker:docker-ce-cli

if [[ -z $* ]]; then
  _help
  exit
fi

if [[ "${opt_all}" == "true" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Restart")] $(_c LIGHT_CYAN "Restarting all containers...")"
  docker container restart $(docker ps -aq) >/dev/null 2>&1
  echo -e "[$(_c LIGHT_BLUE "Docker - Restart")] $(_c LIGHT_CYAN "All containers restarted")"
else
  if [[ $# -eq 1 ]]; then
    container_text="Container"
  else
    container_text="Containers"
  fi

  read -ra arr <<<$*
  inputs=()
  for i in "${@}"; do
    i=$(echo "${i}" | xargs) # trim spaces
    if [[ -n $(docker ps -aq --filter "name=^${i}\$") ]]; then
      inputs+=("${i}")
    else
      echo -e "[$(_c LIGHT_BLUE "Docker - Restart")] $(_c LIGHT_RED "Container") ${i} $(_c LIGHT_RED "does not exist")"
    fi
  done
  containers=$(printf "$(_c LIGHT_BLUE %s), " "${inputs[@]}" | sed 's/, $//')

  if [[ -z "${inputs[@]}" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Docker - Restart")] $(_c LIGHT_RED "No containers to start")"
    exit
  fi

  echo -e "[$(_c LIGHT_BLUE "Docker - Restart")] ${container_text} ${containers} $(_c LIGHT_CYAN "restarting...")"
  docker container restart "${inputs[@]}" >/dev/null 2>&1
  echo -e "[$(_c LIGHT_BLUE "Docker - Restart")] ${container_text} ${containers} $(_c LIGHT_CYAN "restarted")"
fi
