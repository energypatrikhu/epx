_cci docker

game_server_name="${1-}"
if [[ -z "${game_server_name}" ]]; then
  echo "Usage: gsm.stop <game-server-name>"
  exit 1
fi

d.stop "linuxgsm-${game_server_name}"
