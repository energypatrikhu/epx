_cci docker

game_server_name="${1-}"
if [[ -z "${game_server_name}" ]]; then
  echo "Usage: gsm.start <game-server-name>"
  exit 1
fi

d.start "linuxgsm-${game_server_name}"
