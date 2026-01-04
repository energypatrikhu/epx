_help() {
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Restart")] Usage: $(_c LIGHT_YELLOW "mc.restart <server_name>")"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Restart")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Restart")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Restart")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Restart")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Restart")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Restart")]   mc.restart myserver"
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

d.restart "mc-${1-}-server"

if docker ps -a --format '{{.Names}}' | grep -q "^mc-${1-}-backup$"; then
  d.restart "mc-${1-}-backup"
fi
