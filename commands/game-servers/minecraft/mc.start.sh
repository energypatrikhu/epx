if [[ ! -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  echo "Error: Minecraft configuration file not found. Please configure '${EPX_HOME}/.config/minecraft.config' and run 'mc.install'."
  exit 1
fi

_cci docker

. "${EPX_HOME}/.config/minecraft.config"

source "${EPX_HOME}/commands/game-servers/minecraft/_helpers.sh"

if [[ ! -d "${MINECRAFT_PROJECT_DIR}" ]]; then
  echo "Error: Minecraft project directory does not exist. Please run 'mc.install' first."
  exit 1
fi

__epx-mc-get-env-value() {
  local config_env="${1-}"
  local var_name="${2-}"
  grep -iE "^${var_name}\s*=" "${config_env}" | sed -E "s/^${var_name}\s*=\s*//I; s/[[:space:]]*$//"
}
__epx-mc-get-java-type() {
  local config_env="${1-}"
  local java_version=$(__epx-mc-get-env-value "${config_env}" "JAVA_VERSION")

  # if version 8 use "graalvm-ce"
  # else use "graalvm"
  if [[ "${java_version}" == "8" ]]; then
    echo "graalvm-ce"
  else
    echo "graalvm"
  fi
}
__epx-mc-get-backup-enabled() {
  local config_env="${1-}"
  local backup_enabled=$(__epx-mc-get-env-value "${config_env}" "BACKUP")
  if [[ "${backup_enabled,,}" == "true" ]]; then
    echo "true"
  else
    echo "false"
  fi
}

if [[ -z "${1-}" ]]; then
  echo "Usage: mc.start <server>"
  echo "Available servers:"
  __epx-mc-get-configs "${1-}" | sed 's/^/  /'
  exit 1
fi

file_basename=$(basename -- "${1-}")
file_basename="${file_basename%.env}"
server_type=$(echo "${file_basename}" | awk -F'_' '{print $1}')
project_name="mc_${file_basename}"
compose_file_base="${MINECRAFT_PROJECT_DIR}/compose/docker-compose.base.yml"
compose_file_full="${MINECRAFT_PROJECT_DIR}/compose/docker-compose.full.yml"
config_env="${MINECRAFT_PROJECT_DIR}/configs/${file_basename}.env"
java_type=$(__epx-mc-get-java-type "${config_env}")
backup_enabled=$(__epx-mc-get-backup-enabled "${config_env}")

if [[ ! -f "${config_env}" ]]; then
  echo "Error: Environment file ${config_env} does not exist."
  exit 1
fi

# create a tmp env file with the JAVA_TYPE variable
tmp_env_file=$(mktemp)
echo "SERVER_TYPE = ${server_type}" >>"${tmp_env_file}"
echo "SERVER_DIR = ${MINECRAFT_SERVERS_DIR}" >>"${tmp_env_file}"
echo "JAVA_TYPE = ${java_type}" >>"${tmp_env_file}"

echo -e "Starting Minecraft Server"
if [[ "${backup_enabled}" == "true" ]]; then
  echo "BACKUP_DIR = ${MINECRAFT_BACKUPS_DIR}" >>"${tmp_env_file}"
  echo -e "> Backup is enabled"
else
  echo -e "> Backup is disabled"
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
  if [[ ! -f "${compose_file_full}" ]]; then
    echo "Error: Docker Compose file ${compose_file_full} does not exist."
    exit 1
  fi

  docker compose -p "${project_name}" \
    --env-file "${tmp_env_file}" \
    --env-file "${config_env}" \
    -f "${compose_file_full}" \
    up -d
else
  if [[ ! -f "${compose_file_base}" ]]; then
    echo "Error: Docker Compose file ${compose_file_base} does not exist."
    exit 1
  fi

  docker compose -p "${project_name}" \
    --env-file "${tmp_env_file}" \
    --env-file "${config_env}" \
    -f "${compose_file_base}" \
    up -d
fi

# clean up the tmp env file
rm -f "${tmp_env_file}"
