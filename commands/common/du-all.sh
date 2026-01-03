_help() {
  echo -e "[$(_c LIGHT_BLUE "Common - Docker Pull All")] Usage: $(_c LIGHT_YELLOW "du-all")"
  echo -e "[$(_c LIGHT_BLUE "Common - Docker Pull All")] Pull the latest versions of all Docker images on the system"
  echo -e "[$(_c LIGHT_BLUE "Common - Docker Pull All")]"
  echo -e "[$(_c LIGHT_BLUE "Common - Docker Pull All")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Common - Docker Pull All")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "Common - Docker Pull All")]"
  echo -e "[$(_c LIGHT_BLUE "Common - Docker Pull All")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Common - Docker Pull All")]   du-all"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "Common - Docker Pull All")] $(_c LIGHT_RED "Unknown option:") ${arg}"
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

docker images | awk '(NR>1) && ($2!~/none/) {print $1":"$2}' | xargs -L1 docker pull
