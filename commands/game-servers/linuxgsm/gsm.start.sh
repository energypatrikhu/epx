_help() {
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] Usage: $(_c LIGHT_YELLOW "gsm.start <game-server-tag>")"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] Start a LinuxGSM game server Docker container"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] Options:"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]   gsm.start cs2"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]   gsm.start csgo-server"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg docker:docker-ce-cli

game_server_name="${1-}"
if [[ -z "${game_server_name}" ]]; then
  _help
  exit 1
fi

d.start "linuxgsm-${game_server_name}"
