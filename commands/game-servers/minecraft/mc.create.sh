source "${EPX_HOME}/helpers/header.sh"

if [[ ! -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  echo "Error: Minecraft configuration file not found. Please configure '${EPX_HOME}/.config/minecraft.config' and run 'mc.install'."
  exit 1
fi
. "${EPX_HOME}/.config/minecraft.config"

source "${EPX_HOME}/commands/game-servers/minecraft/_helpers.sh"

server_type="${1-}"
server_name="${2-}"

if [[ -z "${server_type}" ]]; then
  echo "Usage: mc.create <server_type> [server_name]"
  echo "Available server types:"
  __epx-mc-get-configs-examples | sed 's/^/  /'
  exit 1
fi

config_file="${MINECRAFT_PROJECT_DIR}/configs/examples/@example.${server_type}.env"
if [[ ! -f "${config_file}" ]]; then
  echo "Error: Configuration file for server type '${server_type}' does not exist."
  echo "Available server types:"
  __epx-mc-get-configs-examples | sed 's/^/  /'
  exit 1
fi

date=$(date +%Y-%m-%d)
new_config_file="${MINECRAFT_PROJECT_DIR}/configs/${server_type}_${date}_${server_name:-CHANGEME}.env"

if [[ -f "${new_config_file}" ]]; then
  echo "Error: Configuration file '${new_config_file}' already exists. Please choose a different name."
  exit 1
fi

touch "${new_config_file}"
while IFS= read -r line; do
  if [[ "${line}" == "CREATED_AT = "* ]]; then
    line="CREATED_AT = ${date}"
  fi
  if [[ "${line}" == "SERVER_NAME = "* ]]; then
    if [[ -n "${server_name}" ]]; then
      line="SERVER_NAME = ${server_name}"
    else
      line="SERVER_NAME = CHANGE ME"
    fi
  fi

  echo "${line}" >>"${new_config_file}"
done <"${config_file}"

echo "Configuration file '${new_config_file}' created successfully."
if [[ -z "${server_name}" ]]; then
  echo "Please replace 'CHANGEME' in the filename with your desired server name or modpack name."
fi
echo "You can now edit the configuration file '${new_config_file}' to set up your server."
