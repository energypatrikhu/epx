_help() {
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Stop")] Usage: $(_c LIGHT_YELLOW "mc.stop <server_name>")"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Stop")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Stop")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Stop")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Stop")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Stop")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Stop")]   mc.stop myserver"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "Minecraft - Stop")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

d.stop "mc-${1-}-server"

if docker ps -a --format '{{.Names}}' | grep -q "^mc-${1-}-backup$"; then
  d.stop "mc-${1-}-backup"
fi
