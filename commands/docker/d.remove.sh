_help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - Remove")] Usage: $(_c LIGHT_YELLOW "d.rm <all / container>")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Remove")] Remove one or more Docker containers or all containers"
  echo -e "[$(_c LIGHT_BLUE "Docker - Remove")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Remove")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Remove")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "Docker - Remove")]   -a, --all         Remove all containers"
  echo -e "[$(_c LIGHT_BLUE "Docker - Remove")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Remove")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Remove")]   d.rm --all"
  echo -e "[$(_c LIGHT_BLUE "Docker - Remove")]   d.rm my_container"
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
      echo -e "[$(_c LIGHT_BLUE "Docker - Remove")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg docker:docker-ce-cli

if [[ -z $* ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Remove")] $(_c LIGHT_YELLOW "Usage: d.rm <all / container>")"
  exit
fi

if [[ "${opt_all}" == "true" ]]; then
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
