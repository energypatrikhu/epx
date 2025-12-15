_cci docker

if [[ ! -f "${EPX_HOME}/.config/docker.config" ]]; then
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_RED "Config file not found, please create one at") ${EPX_HOME}/.config/docker.config"
  exit
fi

. "${EPX_HOME}/.config/docker.config"

game_server_tag="${1-}"
if [[ -z "${game_server_tag}" ]]; then
  echo "Usage: gsm.add <game-server-tag>"
  echo "Example: gsm.add cs2"
  echo "Available game server tags can be found at: https://github.com/GameServerManagers/LinuxGSM/blob/master/lgsm/data/serverlist.csv"
  exit 1
fi

mkdir -p "${CONTAINERS_DIR}/${game_server_tag}"
cp "${EPX_HOME}/.templates/linuxgsm/docker-compose.template" "${CONTAINERS_DIR}/${game_server_tag}/docker-compose.yml"
sed -i "s/TAG/${game_server_tag}/g" "${CONTAINERS_DIR}/${game_server_tag}/docker-compose.yml"

echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_GREEN "Successfully added LinuxGSM game server with tag") ${game_server_tag}"
