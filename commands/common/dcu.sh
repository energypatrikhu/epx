_help() {
  echo -e "[$(_c LIGHT_BLUE "Docker Compose Up")] Usage: $(_c LIGHT_YELLOW "dcu")"
  echo -e "[$(_c LIGHT_BLUE "Docker Compose Up")] Bring up Docker Compose services with the latest images"
  echo -e "[$(_c LIGHT_BLUE "Docker Compose Up")]"
  echo -e "[$(_c LIGHT_BLUE "Docker Compose Up")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Docker Compose Up")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "Docker Compose Up")]"
  echo -e "[$(_c LIGHT_BLUE "Docker Compose Up")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Docker Compose Up")]   dcu"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg docker:docker-ce-cli

docker compose up --detach --pull always
