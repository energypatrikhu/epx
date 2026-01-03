_help() {
  echo -e "[$(_c LIGHT_BLUE "Minecraft - List")] Usage: $(_c LIGHT_YELLOW "mc.list")"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - List")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - List")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - List")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - List")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - List")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - List")]   mc.list"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "Minecraft - List")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

if [[ ! -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - List")] $(_c LIGHT_RED "Error:") Minecraft configuration file not found. Please configure $(_c LIGHT_YELLOW "${EPX_HOME}/.config/minecraft.config") and run $(_c LIGHT_CYAN "mc.install")"
  exit 1
fi

. "${EPX_HOME}/.config/minecraft.config"

if [[ -z "${MINECRAFT_DIR:-}" ]]; then
  echo "Error: MINECRAFT_DIR is not set in your configuration, please set it in your .config/minecraft.config file."
  exit 1
fi
if [[ ! -d "${MINECRAFT_DIR}" ]]; then
  echo "Error: Minecraft project directory does not exist. Please run mc.install first."
  exit 1
fi

source "${EPX_HOME}/commands/game-servers/minecraft/_helpers.sh"

echo -e "[$(_c LIGHT_BLUE "Minecraft - List")] $(_c LIGHT_GREEN "Available Minecraft Servers:")"
__epx-mc-get-servers | sed 's/^/  /'
echo -e "[$(_c LIGHT_BLUE "Minecraft - List")] $(_c LIGHT_YELLOW "Usage:") $(_c LIGHT_CYAN "mc.start <server_name>")"
