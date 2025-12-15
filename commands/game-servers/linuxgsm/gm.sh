_cci docker

game_server_name="${1-}"
if [[ -z "${game_server_name}" ]]; then
  echo "Usage: gm <game-server-name> <command>"
  echo "Example: gm cs2server start"
  exit 1
fi

docker exec -it --user linuxgsm ${game_server_name} ./${game_server_name} ${*:2}
