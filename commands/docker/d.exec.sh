_help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - Exec")] Usage: $(_c LIGHT_YELLOW "d.exec <container> <command> [args]")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Exec")] Execute a command inside a specified Docker container"
  echo -e "[$(_c LIGHT_BLUE "Docker - Exec")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Exec")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Exec")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "Docker - Exec")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Exec")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Exec")]   d.exec my_container ls -la"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "Docker - Exec")] $(_c LIGHT_RED "Unknown option:") ${arg}"
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

if [[ $# -lt 2 ]]; then
  _help
  exit
fi

docker exec -it "${@}"
