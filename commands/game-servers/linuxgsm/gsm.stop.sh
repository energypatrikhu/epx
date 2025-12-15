_cci docker

game_server_name="${1-}"
if [[ -z "${game_server_name}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_RED "Usage:") gsm.stop <game-server-tag>"
  exit 1
fi

d.stop "linuxgsm-${game_server_name}"
