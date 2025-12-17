if [[ ! -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  echo "Error: Minecraft configuration file not found. Please configure '${EPX_HOME}/.config/minecraft.config' and run 'mc.install'."
  exit 1
fi
. "${EPX_HOME}/.config/minecraft.config"

if [[ -z "${MINECRAFT_DIR}" ]]; then
  echo "Error: MINECRAFT_DIR is not set in your configuration, please set it in your .config/minecraft.config file."
  exit 1
fi

source "${EPX_HOME}/commands/game-servers/minecraft/_helpers.sh"

if ! git clone https://github.com/energypatrikhu/minecraft-server "${MINECRAFT_DIR}"; then
  echo "Error: Failed to clone the Minecraft server repository."
  exit 1
fi

echo "Minecraft project install completed successfully."
echo "You can now configure your Minecraft servers."
echo "To pull changes from git, use 'mc.update'."
echo
echo "Minecraft project directory is located at ${MINECRAFT_DIR}"
echo "Setup the curseforge api key in ${MINECRAFT_DIR}/internals/secrets/curseforge_api_key.txt"
echo "Create a new server, use the command: mc.add <server_type> <server_name>"
echo "To show available servers and usage, use the command: mc.list"
echo "To start a server, use the command: mc.start <server_name>"
