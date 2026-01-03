_help() {
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Log")] Usage: $(_c LIGHT_YELLOW "mc.log <server_name>")"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Log")] View the logs of a Minecraft server container"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Log")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Log")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Log")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Log")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Log")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Log")]   mc.log myserver"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "Minecraft - Log")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

d.log "mc-${1-}-server"
