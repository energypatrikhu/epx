_help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - Stop")] Usage: $(_c LIGHT_YELLOW "d.stop <all / container>")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Stop")] Stop one or more Docker containers or all containers"
  echo -e "[$(_c LIGHT_BLUE "Docker - Stop")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Stop")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Stop")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "Docker - Stop")]   -a, --all         Stop all running containers"
  echo -e "[$(_c LIGHT_BLUE "Docker - Stop")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Stop")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Stop")]   d.stop --all"
  echo -e "[$(_c LIGHT_BLUE "Docker - Stop")]   d.stop my_container"
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
  echo -e "[$(_c LIGHT_BLUE 'Docker - Stop')] $(_c LIGHT_YELLOW "Usage: d.stop <all / container>")"
  exit
fi

if [[ "${opt_all}" == "true" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Stop")] $(_c LIGHT_RED "Stopping all containers...")"
  docker container stop $(docker ps -aq) >/dev/null 2>&1
  echo -e "[$(_c LIGHT_BLUE "Docker - Stop")] $(_c LIGHT_RED "All containers stopped")"
else
  if [[ $# -eq 1 ]]; then
    container_text="Container"
  else
    container_text="Containers"
  fi

  read -ra arr <<<$*
  inputs=""
  for i in "${@}"; do
    i=$(echo "${i}" | xargs) # trim spaces
    if [[ -n $(docker ps -aq --filter "name=^${i}\$") ]]; then
      inputs+="${i}"
    else
      echo -e "[$(_c LIGHT_BLUE "Docker - Stop")] $(_c LIGHT_RED "Container") ${i} $(_c LIGHT_RED "does not exist")"
    fi
  done
  containers=$(printf "$(_c LIGHT_BLUE %s)," "${inputs}" | sed 's/, $//' | sed 's/,$//')

  if [[ -z "${inputs}" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Docker - Stop")] $(_c LIGHT_RED "No containers to start")"
    exit
  fi

  echo -e "[$(_c LIGHT_BLUE "Docker - Stop")] ${container_text} ${containers} $(_c LIGHT_RED "stopping...")"
  docker container stop "${inputs}" >/dev/null 2>&1
  echo -e "[$(_c LIGHT_BLUE "Docker - Stop")] ${container_text} ${containers} $(_c LIGHT_RED "stopped")"
fi
