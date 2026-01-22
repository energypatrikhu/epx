_help() {
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")] Usage: $(_c LIGHT_YELLOW "mc.start <server_name>")"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")]   mc.start myserver"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

if [[ ! -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")] $(_c LIGHT_RED "Error:") Minecraft configuration file not found. Please configure $(_c LIGHT_YELLOW "${EPX_HOME}/.config/minecraft.config") and run $(_c LIGHT_CYAN "mc.install")"
  exit 1
fi

_cci_pkg docker:docker-ce-cli

. "${EPX_HOME}/.config/minecraft.config"

if [[ -z "${MINECRAFT_DIR:-}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")] $(_c LIGHT_RED "Error:") MINECRAFT_DIR is not set in your configuration, please set it in your $(_c LIGHT_YELLOW ".config/minecraft.config") file."
  exit 1
fi
if [[ ! -d "${MINECRAFT_DIR}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")] $(_c LIGHT_RED "Error:") Minecraft project directory does not exist. Please run $(_c LIGHT_CYAN "mc.install") first."
  exit 1
fi

source "${EPX_HOME}/commands/game-servers/minecraft/_helpers.sh"

server_dir="${1-}"

if [[ -z "${server_dir}" ]]; then
  _help
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")]"
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")] Available servers:"
  __epx-mc-get-servers "${server_dir}" | sed 's/^/  /'
  exit 1
fi

if ! __epx-mc-get-servers | grep -qx "${server_dir}"; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")] $(_c LIGHT_RED "Error:") Server $(_c LIGHT_YELLOW "${server_dir}") not found."
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")] Available servers:"
  __epx-mc-get-servers | sed 's/^/  /'
  exit 1
fi

server_dir_full="${MINECRAFT_DIR}/servers/${server_dir}"

if [[ ! -d "${server_dir_full}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")] $(_c LIGHT_RED "Error:") Server directory $(_c LIGHT_YELLOW "${server_dir}") does not exist."
  exit 1
fi

server_type="$(__epx-mc-get-platform-type "${server_dir_full}")"
project_name="mc_${server_dir}"
config_env="${server_dir_full}/config.env"
whitelist_file="${server_dir_full}/whitelist.txt"
ops_file="${server_dir_full}/ops.txt"
backup_enabled=$(__epx-mc-get-backup-enabled "${config_env}")

whitelist_file_content="$(grep -v '^[[:space:]]*#' "${whitelist_file}" 2>/dev/null | grep '[^[:space:]]')" || whitelist_file_content=""
ops_file_content="$(grep -v '^[[:space:]]*#' "${ops_file}" 2>/dev/null | grep '[^[:space:]]')" || ops_file_content=""

# create a tmp env file to hold dynamic variables
tmp_env_file=$(mktemp)
echo "SERVER_TYPE = ${server_type}" >>"${tmp_env_file}"
echo "SERVER_DIR = ${server_dir}" >>"${tmp_env_file}"
if [[ -n "${ops_file_content}" ]]; then
  echo "OPS = $(__epx-mc-multiline-to-comma-separated "${ops_file_content}")" >>"${tmp_env_file}"
fi
if [[ -n "${whitelist_file_content}" ]]; then
  echo "WHITELIST = $(__epx-mc-multiline-to-comma-separated "${whitelist_file_content}")" >>"${tmp_env_file}"
fi

echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")] $(_c LIGHT_GREEN "Starting Minecraft Server")"
if [[ "${backup_enabled}" == "true" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")] > Backup is $(_c LIGHT_GREEN "enabled")"
else
  echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")] > Backup is $(_c LIGHT_RED "disabled")"
fi

api_key_warning=""
if [[ -f "${MINECRAFT_DIR}/internals/secrets/curseforge_api_key.txt" ]]; then
  if [[ ! -s "${MINECRAFT_DIR}/internals/secrets/curseforge_api_key.txt" ]]; then
    api_key_warning="[$(_c LIGHT_BLUE "Minecraft - Start")] $(_c LIGHT_YELLOW "Warning:") CurseForge API key file is empty. You may need to set your API key in $(_c LIGHT_YELLOW "${MINECRAFT_DIR}/internals/secrets/curseforge_api_key.txt") to download CurseForge mods."
  fi
else
  api_key_warning="[$(_c LIGHT_BLUE "Minecraft - Start")] $(_c LIGHT_YELLOW "Warning:") CurseForge API key file not found at $(_c LIGHT_YELLOW "${MINECRAFT_DIR}/internals/secrets/curseforge_api_key.txt"). You may need to create this file and add your API key to download CurseForge mods."
fi

if [[ -n "${api_key_warning}" ]] && [[ -f "${server_dir_full}/mods.curseforge.txt" ]] && [[ -s "${server_dir_full}/mods.curseforge.txt" ]]; then
  if grep -v '^[[:space:]]*#' "${server_dir_full}/mods.curseforge.txt" | grep -q '[^[:space:]]'; then
    echo ""
    echo -e "${api_key_warning}"
    echo ""
    echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")] $(_c LIGHT_RED "Error:") Cannot start server because CurseForge mods are configured but API key is not set."
    rm -f "${tmp_env_file}"
    exit 1
  fi
fi

if [[ "${backup_enabled}" == "true" ]]; then
  docker compose \
    -p "${project_name}" \
    --env-file "${tmp_env_file}" \
    --env-file "${config_env}" \
    -f "${MINECRAFT_DIR}/internals/compose/itzg-config.yml" \
    -f "${MINECRAFT_DIR}/internals/compose/itzg-mc-backup.yml" \
    -f "${MINECRAFT_DIR}/internals/compose/itzg-mc.yml" \
    up -d
else
  docker compose \
    -p "${project_name}" \
    --env-file "${tmp_env_file}" \
    --env-file "${config_env}" \
    -f "${MINECRAFT_DIR}/internals/compose/itzg-config.yml" \
    -f "${MINECRAFT_DIR}/internals/compose/itzg-mc.yml" \
    up -d
fi

rm -f "${tmp_env_file}"
echo -e "[$(_c LIGHT_BLUE "Minecraft - Start")] Minecraft server $(_c LIGHT_YELLOW "${server_dir}") $(_c LIGHT_GREEN "started successfully.")"

if [[ -n "${api_key_warning}" ]]; then
  echo ""
  echo -e "${api_key_warning}"
  echo ""
fi
