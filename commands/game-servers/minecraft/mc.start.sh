if [[ ! -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  echo "Error: Minecraft configuration file not found. Please configure '${EPX_HOME}/.config/minecraft.config' and run 'mc.install'."
  exit 1
fi

_cci docker

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

server_dir="${1-}"

if [[ -z "${server_dir}" ]]; then
  echo "Usage: mc.start <server>"
  echo "Available servers:"
  __epx-mc-get-servers "${server_dir}" | sed 's/^/  /'
  exit 1
fi

if ! __epx-mc-get-servers | grep -qx "${server_dir}"; then
  echo "Error: Server '${server_dir}' not found."
  echo "Available servers:"
  __epx-mc-get-servers | sed 's/^/  /'
  exit 1
fi

server_dir_full="${MINECRAFT_DIR}/servers/${server_dir}"

if [[ ! -d "${server_dir_full}" ]]; then
  echo "Error: Server directory '${server_dir}' does not exist."
  exit 1
fi

server_type=$(echo "${server_dir}" | awk -F'_' '{print $1}')
server_name=$(echo "${server_dir}" | awk -F'_' '{print $2}')
project_name="mc_${server_dir}"
config_env="${server_dir_full}/config.env"
backup_enabled=$(__epx-mc-get-backup-enabled "${config_env}")

# create a tmp env file to hold dynamic variables
tmp_env_file=$(mktemp)
echo "SERVER_TYPE = ${server_type}" >>"${tmp_env_file}"
echo "SERVER_DIR = ${server_dir}" >>"${tmp_env_file}"

echo "Starting Minecraft Server"
if [[ "${backup_enabled}" == "true" ]]; then
  echo "> Backup is enabled"
else
  echo "> Backup is disabled"
fi

echo -e "> Environment Variables:"
if [[ -s "${config_env}" ]]; then
  grep -v '^[[:space:]]*#' "${config_env}" | grep -E '^[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=' | while IFS= read -r line; do
    echo "  - ${line}"
  done
else
  echo "  (No variables in ${config_env})"
fi
if [[ -s "${tmp_env_file}" ]]; then
  grep -v '^[[:space:]]*#' "${tmp_env_file}" | grep -E '^[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=' | while IFS= read -r line; do
    echo "  - ${line}"
  done
else
  echo "  (No variables in ${tmp_env_file})"
fi

if [[ "${backup_enabled}" == "true" ]]; then
  docker compose \
    -p "${project_name}" \
    --env-file "${tmp_env_file}" \
    --env-file "${config_env}" \
    -f "${MINECRAFT_DIR}/internals/itzg-config.yml" \
    -f "${MINECRAFT_DIR}/internals/itzg-mc-backup.yml" \
    -f "${MINECRAFT_DIR}/internals/itzg-mc.yml" \
    up -d
else
  docker compose \
    -p "${project_name}" \
    --env-file "${tmp_env_file}" \
    --env-file "${config_env}" \
    -f "${MINECRAFT_DIR}/internals/itzg-config.yml" \
    -f "${MINECRAFT_DIR}/internals/itzg-mc.yml" \
    up -d
fi

rm -f "${tmp_env_file}"
echo "Minecraft server '${server_dir}' started successfully."
