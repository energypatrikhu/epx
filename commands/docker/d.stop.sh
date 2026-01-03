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
    else
      echo -e "[$(_c LIGHT_BLUE "Docker - Stop")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci docker

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
