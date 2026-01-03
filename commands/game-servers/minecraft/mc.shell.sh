_help() {
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Shell")] Usage: $(_c LIGHT_YELLOW "mc.shell <server_name>")"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Shell")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Shell")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Shell")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Shell")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Shell")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Shell")]   mc.shell myserver"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "Minecraft - Shell")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

d.shell "mc-${1-}-server"
