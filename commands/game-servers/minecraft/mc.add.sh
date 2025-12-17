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

server_type="${1-}"
server_name="${2-}"

if [[ -z "${server_type}" || -z "${server_name}" ]]; then
  echo "Usage: mc.add <server_type> <server_name>"
  echo "Available server types:"
  __epx-mc-get-server-templates | sed 's/^/  /'
  exit 1
fi

if ! __epx-mc-get-server-templates | grep -qx "${server_type}"; then
  echo "Error: Server type '${server_type}' not found."
  echo "Available server types:"
  __epx-mc-get-server-templates | sed 's/^/  /'
  exit 1
fi

server_directory="${MINECRAFT_DIR}/servers/${server_type}_${server_name}"

if [[ -d "${server_directory}" ]]; then
  echo "Error: Server directory '${server_directory}' already exists."
  exit 1
fi

platform_template_file="${MINECRAFT_DIR}/internals/templates/platforms/${server_type}"
backup_template_file="${MINECRAFT_DIR}/internals/templates/backup"
properties_template_file="${MINECRAFT_DIR}/internals/templates/properties"
mods_curseforge_template_file="${MINECRAFT_DIR}/internals/templates/mods/curseforge"
mods_modrinth_template_file="${MINECRAFT_DIR}/internals/templates/mods/modrinth"

echo "Creating server directory structure at '${server_directory}'..."

mkdir -p "${server_directory}"
mkdir -p "${server_directory}/data"
mkdir -p "${server_directory}/extras"
mkdir -p "${server_directory}/extras/configs"
mkdir -p "${server_directory}/extras/data"
mkdir -p "${server_directory}/extras/mods"
mkdir -p "${server_directory}/extras/plugins"

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

echo "Populating configuration files from templates..."

echo "${platform_template_file_content}" > "${server_directory}/config.env"
echo "${backup_template_file_content}" >> "${server_directory}/config.env"
echo "${properties_template_file_content}" >> "${server_directory}/config.env"
echo "${mods_curseforge_template_file_content}" > "${server_directory}/mods.curseforge.txt"
echo "${mods_modrinth_template_file_content}" > "${server_directory}/mods.modrinth.txt"

echo "Server '${server_name}' of type '${server_type}' created successfully at '${server_directory}'."
echo "You can now customize the configuration files and start the server using 'mc.up ${server_type}_${server_name}'."
