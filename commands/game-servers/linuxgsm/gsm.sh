_help() {
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] Usage: $(_c LIGHT_YELLOW "gsm <game-server-tag> <command>")"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] If output file is not specified, barcode is displayed in terminal"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] Options:"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]   gsm cs2 start"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]   gsm tf2 stop"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]   gsm gmod restart"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]   gsm terraria status"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]   gsm valheim console"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]   gsm rust details"
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

game_server_name="${1-}"
if [[ -z "${game_server_name}" ]]; then
  _help
  exit 1
fi

docker exec -it --user linuxgsm linuxgsm-${game_server_name} ./${game_server_name}server ${*:2}
