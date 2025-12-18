if [[ ! -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  echo "Error: Minecraft configuration file not found. Please configure '${EPX_HOME}/.config/minecraft.config' and run 'mc.install'."
  exit 1
fi

_cci git

. "${EPX_HOME}/.config/minecraft.config"

if [[ -z "${MINECRAFT_DIR:-}" ]]; then
  echo "Error: MINECRAFT_DIR is not set in your configuration, please set it in your .config/minecraft.config file."
  exit 1
fi
if [[ ! -d "${MINECRAFT_DIR}" ]]; then
  echo "Error: Minecraft project directory does not exist. Please run 'mc.install' first."
  exit 1
fi

cd "${MINECRAFT_DIR}/internals" || exit
if ! git pull; then
  echo "Error: Failed to update the Minecraft project."
  exit 1
fi

echo "Minecraft project updated successfully."
