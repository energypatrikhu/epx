_cci docker

game_server_name="${1-}"
if [[ -z "${game_server_name}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_RED "Usage:") gsm <game-server-tag> <command>"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_YELLOW "Examples:")"
  echo -e "  gsm ${game_server_name} start"
  echo -e "  gsm ${game_server_name} stop"
  echo -e "  gsm ${game_server_name} restart"
  echo -e "  gsm ${game_server_name} status"
  echo -e "  gsm ${game_server_name} console"
  echo -e "  gsm ${game_server_name} details"
  exit 1
fi

docker exec -it --user linuxgsm linuxgsm-${game_server_name} ./${game_server_name}server ${*:2}
