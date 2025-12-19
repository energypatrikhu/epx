if [[ ! -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  echo "Error: Minecraft configuration file not found. Please configure '${EPX_HOME}/.config/minecraft.config' and run 'mc.install'."
  exit 1
fi

. "${EPX_HOME}/.config/minecraft.config"

if [[ -z "${MINECRAFT_DIR:-}" ]]; then
  echo "Error: MINECRAFT_DIR is not set in your configuration, please set it in your .config/minecraft.config file."
  exit 1
fi
if [[ ! -d "${MINECRAFT_DIR}" ]]; then
  echo "Error: Minecraft project directory does not exist. Please run 'mc.install' first."
  exit 1
fi

source "${EPX_HOME}/commands/game-servers/minecraft/_helpers.sh"

echo -e "[$(_c LIGHT_BLUE "Minecraft - List")] $(_c LIGHT_GREEN "Available Minecraft Servers:")"
__epx-mc-get-servers | sed 's/^/  /'
echo -e "[$(_c LIGHT_BLUE "Minecraft - List")] $(_c LIGHT_YELLOW "Usage:") $(_c LIGHT_CYAN "mc.start <server_name>")"
