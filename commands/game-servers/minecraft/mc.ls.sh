_help() {
  echo -e "[$(_c LIGHT_BLUE "Minecraft - List Containers")] Usage: $(_c LIGHT_YELLOW "mc.ls")"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - List Containers")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - List Containers")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - List Containers")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - List Containers")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - List Containers")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - List Containers")]   mc.ls"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

if [[ ! -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - List Containers")] $(_c LIGHT_RED "Error:") Minecraft configuration file not found. Please configure $(_c LIGHT_YELLOW "${EPX_HOME}/.config/minecraft.config") and run $(_c LIGHT_CYAN "mc.install")"
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

echo -e "[$(_c LIGHT_BLUE "Minecraft - List Containers")] $(_c LIGHT_GREEN "Minecraft containers:")"
__epx-mc-get-containers | sed 's/^/  /'
