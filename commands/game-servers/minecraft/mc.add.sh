if [[ ! -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Add")] $(_c LIGHT_RED "Error:") Minecraft configuration file not found. Please configure $(_c LIGHT_YELLOW "'${EPX_HOME}/.config/minecraft.config'") and run $(_c LIGHT_CYAN "'mc.install'")"
  exit 1
fi
. "${EPX_HOME}/.config/minecraft.config"

if [[ -z "${MINECRAFT_DIR:-}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Add")] $(_c LIGHT_RED "Error:") MINECRAFT_DIR is not set in your configuration, please set it in your $(_c LIGHT_YELLOW ".config/minecraft.config") file."
  exit 1
fi
if [[ ! -d "${MINECRAFT_DIR}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Add")] $(_c LIGHT_RED "Error:") Minecraft project directory does not exist. Please run $(_c LIGHT_CYAN "'mc.install'") first."
  exit 1
fi

source "${EPX_HOME}/commands/game-servers/minecraft/_helpers.sh"

server_type="${1-}"
server_name="${2-}"

if [[ -z "${server_type}" || -z "${server_name}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Add")] $(_c LIGHT_YELLOW "Usage:") $(_c LIGHT_CYAN "mc.add <server_type> <server_name>")"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Add")] Available server types:"
  __epx-mc-get-server-templates | sed 's/^/  /'
  exit 1
fi

if ! [[ "${server_name}" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Add")] $(_c LIGHT_RED "Error:") Server name $(_c LIGHT_YELLOW "'${server_name}'") contains invalid characters."
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Add")] Only alphanumeric characters, hyphens (-), periods (.), and underscores (_) are allowed."
  exit 1
fi

if ! __epx-mc-get-server-templates | grep -qx "${server_type}"; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Add")] $(_c LIGHT_RED "Error:") Server type $(_c LIGHT_YELLOW "'${server_type}'") not found."
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Add")] Available server types:"
  __epx-mc-get-server-templates | sed 's/^/  /'
  exit 1
fi

server_directory="${MINECRAFT_DIR}/servers/${server_name}"

if [[ -d "${server_directory}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Add")] $(_c LIGHT_RED "Error:") Server directory $(_c LIGHT_YELLOW "'${server_name}'") already exists."
  exit 1
fi

platform_template_file="${MINECRAFT_DIR}/internals/templates/platforms/${server_type}"
backup_template_file="${MINECRAFT_DIR}/internals/templates/backup"
properties_template_file="${MINECRAFT_DIR}/internals/templates/properties"
mods_curseforge_template_file="${MINECRAFT_DIR}/internals/templates/mods/curseforge"
mods_modrinth_template_file="${MINECRAFT_DIR}/internals/templates/mods/modrinth"

echo -e "[$(_c LIGHT_BLUE "Minecraft - Add")] Creating server directory structure at $(_c LIGHT_YELLOW "'${server_directory}'...")"

mkdir -p "${server_directory}"
mkdir -p "${server_directory}/data"
mkdir -p "${server_directory}/extras"
mkdir -p "${server_directory}/extras/configs"
mkdir -p "${server_directory}/extras/data"
mkdir -p "${server_directory}/extras/mods"
mkdir -p "${server_directory}/extras/plugins"

touch "${server_directory}/.platform-${server_type}"
touch "${server_directory}/config.env"
touch "${server_directory}/mods.curseforge.txt"
touch "${server_directory}/mods.modrinth.txt"
touch "${server_directory}/ops.txt"
touch "${server_directory}/whitelist.txt"

platform_template_file_content=$(cat "${platform_template_file}")
backup_template_file_content=$(cat "${backup_template_file}")
properties_template_file_content=$(cat "${properties_template_file}")
mods_curseforge_template_file_content=$(cat "${mods_curseforge_template_file}")
mods_modrinth_template_file_content=$(cat "${mods_modrinth_template_file}")

echo -e "[$(_c LIGHT_BLUE "Minecraft - Add")] Populating configuration files from templates..."

echo "${platform_template_file_content}" >> "${server_directory}/config.env"
echo "" >> "${server_directory}/config.env"
echo "${backup_template_file_content}" >> "${server_directory}/config.env"
echo "" >> "${server_directory}/config.env"
echo "${properties_template_file_content}" >> "${server_directory}/config.env"
echo "${mods_curseforge_template_file_content}" >> "${server_directory}/mods.curseforge.txt"
echo "${mods_modrinth_template_file_content}" >> "${server_directory}/mods.modrinth.txt"

echo -e "[$(_c LIGHT_BLUE "Minecraft - Add")] $(_c LIGHT_GREEN "Server") $(_c LIGHT_YELLOW "'${server_name}'") $(_c LIGHT_GREEN "of type") $(_c LIGHT_YELLOW "'${server_type}'") $(_c LIGHT_GREEN "created successfully at") $(_c LIGHT_YELLOW "'${server_directory}'")$(_c LIGHT_GREEN ".")"
echo -e "[$(_c LIGHT_BLUE "Minecraft - Add")] You can now customize the configuration files and start the server using $(_c LIGHT_CYAN "'mc.start ${server_type}_${server_name}'")"
echo -e "[$(_c LIGHT_BLUE "Minecraft - Add")] To view all servers, use the command: $(_c LIGHT_CYAN "mc.list")"

if [[ -f "${MINECRAFT_DIR}/internals/secrets/curseforge_api_key.txt" ]]; then
  if [[ ! -s "${MINECRAFT_DIR}/internals/secrets/curseforge_api_key.txt" ]]; then
    echo ""
    echo -e "[$(_c LIGHT_BLUE "Minecraft - Add")] $(_c LIGHT_YELLOW "Warning:") CurseForge API key file is empty. You may need to set your API key in $(_c LIGHT_YELLOW "'${MINECRAFT_DIR}/internals/secrets/curseforge_api_key.txt'") to download CurseForge mods."
  fi
else
  echo ""
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Add")] $(_c LIGHT_YELLOW "Warning:") CurseForge API key file not found at $(_c LIGHT_YELLOW "'${MINECRAFT_DIR}/internals/secrets/curseforge_api_key.txt'"). You may need to create this file and add your API key to download CurseForge mods."
fi
