if [[ ! -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Install")] $(_c LIGHT_RED "Error:") Minecraft configuration file not found. Please configure $(_c LIGHT_YELLOW "${EPX_HOME}/.config/minecraft.config") and run $(_c LIGHT_CYAN "mc.install")"
  exit 1
fi
. "${EPX_HOME}/.config/minecraft.config"

if [[ -z "${MINECRAFT_DIR:-}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Install")] $(_c LIGHT_RED "Error:") MINECRAFT_DIR is not set in your configuration, please set it in your $(_c LIGHT_YELLOW ".config/minecraft.config") file."
  exit 1
fi

source "${EPX_HOME}/commands/game-servers/minecraft/_helpers.sh"

echo -e "[$(_c LIGHT_BLUE "Minecraft - Install")] Cloning repository..."
if ! git clone https://github.com/energypatrikhu/minecraft-server "${MINECRAFT_DIR}/internals"; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Install")] $(_c LIGHT_RED "Error:") Failed to clone the Minecraft server repository."
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "Minecraft - Install")] Setting up Minecraft project structure..."
mkdir -p "${MINECRAFT_DIR}/servers"
mkdir -p "${MINECRAFT_DIR}/internals/secrets"
touch "${MINECRAFT_DIR}/internals/secrets/curseforge_api_key.txt"

echo -e "[$(_c LIGHT_BLUE "Minecraft - Install")] $(_c LIGHT_GREEN "Minecraft project install completed successfully.")"
echo -e "[$(_c LIGHT_BLUE "Minecraft - Install")] You can now configure your Minecraft servers."
echo -e "[$(_c LIGHT_BLUE "Minecraft - Install")] To pull changes from git, use $(_c LIGHT_CYAN "mc.update")"
echo
echo -e "[$(_c LIGHT_BLUE "Minecraft - Install")] Minecraft project directory is located at $(_c LIGHT_YELLOW "${MINECRAFT_DIR}")"
echo -e "[$(_c LIGHT_BLUE "Minecraft - Install")] Setup the curseforge api key in $(_c LIGHT_YELLOW "${MINECRAFT_DIR}/internals/secrets/curseforge_api_key.txt")"
echo -e "[$(_c LIGHT_BLUE "Minecraft - Install")] Create a new server, use the command: $(_c LIGHT_CYAN "mc.add <server_type> <server_name>")"
echo -e "[$(_c LIGHT_BLUE "Minecraft - Install")] To show available servers and usage, use the command: $(_c LIGHT_CYAN "mc.list")"
echo -e "[$(_c LIGHT_BLUE "Minecraft - Install")] To start a server, use the command: $(_c LIGHT_CYAN "mc.start <server_name>")"
