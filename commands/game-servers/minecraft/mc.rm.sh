_help() {
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Remove")] Usage: $(_c LIGHT_YELLOW "mc.rm <server_name>")"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Remove")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Remove")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Remove")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Remove")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Remove")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Remove")]   mc.rm myserver"
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

d.rm "mc-${1-}-server"

if docker ps -a --format '{{.Names}}' | grep -q "^mc-${1-}-backup$"; then
  d.rm "mc-${1-}-backup"
fi
