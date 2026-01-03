_help() {
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Attach")] Usage: $(_c LIGHT_YELLOW "mc.attach <server_name>")"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Attach")] Attach to a running Minecraft server container"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Attach")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Attach")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Attach")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Attach")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Attach")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Attach")]   mc.attach myserver"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "Minecraft - Attach")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

d.attach "mc-${1-}-server"
