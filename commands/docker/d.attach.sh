_help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - Attach")] Usage: $(_c LIGHT_YELLOW "d.attach <container>")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Attach")] Attach to a specified Docker container"
  echo -e "[$(_c LIGHT_BLUE "Docker - Attach")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Attach")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Attach")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "Docker - Attach")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Attach")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Attach")]   d.attach my_container"
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

if [[ -z $* ]]; then
  _help
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "Docker - Attach")] $(_c LIGHT_YELLOW "Warning: Attaching to container") ${@}"
echo -e "[$(_c LIGHT_BLUE "Docker - Attach")] $(_c LIGHT_YELLOW "To detach: Press") Ctrl+C"
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Attach")] $(_c LIGHT_RED "Aborted")"
  exit 0
fi

docker container attach --sig-proxy=false --detach-keys="ctrl-c" "${@}"
