source "${EPX_HOME}/helpers/header.sh"

if [[ ! -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  echo "Error: Minecraft configuration file not found. Please configure '${EPX_HOME}/.config/minecraft.config' and run 'mc.install'."
  exit 1
fi
. "${EPX_HOME}/.config/minecraft.config"

if [[ -z "${MINECRAFT_PROJECT_DIR}" ]]; then
  echo "Error: MINECRAFT_PROJECT_DIR is not set in your configuration, please set it in your .config/minecraft.config file."
  exit 1
fi

if ! command -v git &>/dev/null; then
  echo "Error: git is not installed. Please install git to run this command."
  exit 1
fi

if ! git clone https://github.com/energypatrikhu/minecraft-server "${MINECRAFT_PROJECT_DIR}"; then
  echo "Error: Failed to clone the Minecraft repository."
  exit 1
fi

echo "Minecraft project install completed successfully."
echo "You can now configure your Minecraft servers."
echo "To pull changes from git, use 'mc.update'."

echo "Minecraft project directory is located at ${MINECRAFT_PROJECT_DIR}"
echo "Setup the curseforge api key in ${MINECRAFT_PROJECT_DIR}/secrets/curseforge_api_key.txt"
echo "Create a new server configuration file in ${MINECRAFT_PROJECT_DIR}/configs by copying the example files"

echo "To show available servers and usage, use the command: mc"
echo "To start a server, use the command: mc <server_name>"
echo "To create a new server configuration file, use the command: mc.create <server_type>"
