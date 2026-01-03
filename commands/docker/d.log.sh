_help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - Logs")] Usage: $(_c LIGHT_YELLOW "d.logs <container> [-a | --all]")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Logs")] Follow logs of a specified Docker container"
  echo -e "[$(_c LIGHT_BLUE "Docker - Logs")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Logs")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Logs")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "Docker - Logs")]   -a, --all         Show all logs from the container start time"
  echo -e "[$(_c LIGHT_BLUE "Docker - Logs")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Logs")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Logs")]   d.logs my_container"
  echo -e "[$(_c LIGHT_BLUE "Docker - Logs")]   d.logs my_container --all"
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
      echo -e "[$(_c LIGHT_BLUE "Docker - Logs")] $(_c LIGHT_RED "Unknown option:") ${arg}"
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
  _help
  exit
fi

if [[ "${opt_all}" == "true" ]]; then
  docker container logs -f "${1-}" --since "$(docker inspect "${1-}" | jq .[0].State.StartedAt | sed 's/"//g')"
  exit
fi

docker container logs -f "${@}"
