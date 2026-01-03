_help() {
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] Usage: $(_c LIGHT_YELLOW "gsm.add <game-server-tag>")"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] Add a new LinuxGSM game server container"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] Options:"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]   gsm.add cs2"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci docker

if [[ ! -f "${EPX_HOME}/.config/docker.config" ]]; then
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_RED "Config file not found, please create one at") ${EPX_HOME}/.config/docker.config"
  exit
fi

. "${EPX_HOME}/.config/docker.config"

game_server_tag="${1-}"
if [[ -z "${game_server_tag}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_RED "Usage:") gsm.add <game-server-tag>"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_YELLOW "Example:") gsm.add cs2"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_YELLOW "Available game server tags can be found at:") https://github.com/GameServerManagers/LinuxGSM/blob/master/lgsm/data/serverlist.csv"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_YELLOW "Or use:") gsm.list [search-term]"
  exit 1
fi

available_tags="$(curl -sL https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/refs/heads/master/lgsm/data/serverlist.csv | cut -d, -f1 | tail -n +2)"
if ! echo "${available_tags}" | grep -qx "${game_server_tag}"; then
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_RED "Invalid game server tag:") ${game_server_tag}"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_RED "Available game server tags can be found at:") https://github.com/GameServerManagers/LinuxGSM/blob/master/lgsm/data/serverlist.csv"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_RED "Or use:") gsm.list [search-term]"
  exit 1
fi

if [[ -d "${CONTAINERS_DIR}/linuxgsm-${game_server_tag}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_RED "A LinuxGSM game server with tag") ${game_server_tag} $(_c LIGHT_RED "already exists.")"
  exit 1
fi

mkdir -p "${CONTAINERS_DIR}/linuxgsm-${game_server_tag}"
cp "${EPX_HOME}/.templates/linuxgsm/docker-compose.template" "${CONTAINERS_DIR}/linuxgsm-${game_server_tag}/docker-compose.yml"
sed -i "s/TAG/${game_server_tag}/g" "${CONTAINERS_DIR}/linuxgsm-${game_server_tag}/docker-compose.yml"

echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_GREEN "Successfully added LinuxGSM game server with tag") ${game_server_tag}"
d.up "linuxgsm-${game_server_tag}"
