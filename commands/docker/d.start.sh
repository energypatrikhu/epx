_help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - Start")] Usage: $(_c LIGHT_YELLOW "d.start <all / container>")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Start")] Start one or more Docker containers or all containers"
  echo -e "[$(_c LIGHT_BLUE "Docker - Start")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Start")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Start")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "Docker - Start")]   -a, --all         Start all stopped containers"
  echo -e "[$(_c LIGHT_BLUE "Docker - Start")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Start")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Start")]   d.start --all"
  echo -e "[$(_c LIGHT_BLUE "Docker - Start")]   d.start my_container"
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
  echo -e "[$(_c LIGHT_BLUE "Docker - Start")] $(_c LIGHT_YELLOW "Usage: d.start <all / container>")"
  exit
fi

if [[ "${opt_all}" == "true" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Start")] $(_c LIGHT_GREEN "Starting all containers...")"
  docker container start $(docker ps -aq) >/dev/null 2>&1
  echo -e "[$(_c LIGHT_BLUE "Docker - Start")] $(_c LIGHT_GREEN "All containers started")"
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

  echo -e "[$(_c LIGHT_BLUE "Docker - Start")] ${container_text} $(_c LIGHT_BLUE "${containers}") $(_c LIGHT_GREEN "starting...")"
  docker container start "${@}" >/dev/null 2>&1
  echo -e "[$(_c LIGHT_BLUE "Docker - Start")] ${container_text} $(_c LIGHT_BLUE "${containers}") $(_c LIGHT_GREEN "started")"
fi
