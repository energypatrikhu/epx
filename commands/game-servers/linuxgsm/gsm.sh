_cci docker

game_server_name="${1-}"
if [[ -z "${game_server_name}" ]]; then
  echo "Usage: gsm <game-server-name> <command>"
  echo "Example: gsm cs2server start"
  exit 1
fi

docker exec -it --user linuxgsm linuxgsm-${game_server_name} ./${game_server_name} ${*:2}
