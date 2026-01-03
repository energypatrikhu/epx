_help() {
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Update")] Usage: $(_c LIGHT_YELLOW "mc.update")"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Update")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Update")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Update")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Update")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Update")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Update")]   mc.update"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "IT - Barcode")] $(_c LIGHT_RED "Unknown option:") ${arg}"
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
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Update")] $(_c LIGHT_RED "Error:") Minecraft configuration file not found. Please configure $(_c LIGHT_YELLOW "${EPX_HOME}/.config/minecraft.config") and run $(_c LIGHT_CYAN "mc.install")"
  exit 1
fi

_cci git

. "${EPX_HOME}/.config/minecraft.config"

if [[ -z "${MINECRAFT_DIR:-}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Update")] $(_c LIGHT_RED "Error:") MINECRAFT_DIR is not set in your configuration, please set it in your $(_c LIGHT_YELLOW ".config/minecraft.config") file."
  exit 1
fi
if [[ ! -d "${MINECRAFT_DIR}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Update")] $(_c LIGHT_RED "Error:") Minecraft project directory does not exist. Please run $(_c LIGHT_CYAN "mc.install") first."
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "Minecraft - Update")] Updating project..."
cd "${MINECRAFT_DIR}/internals" || exit
if ! git pull; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Update")] $(_c LIGHT_RED "Error:") Failed to update the Minecraft project."
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "Minecraft - Update")] $(_c LIGHT_GREEN "Minecraft project updated successfully.")"
