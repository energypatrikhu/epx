_cci docker

game_server_name="${1-}"
if [[ -z "${game_server_name}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_RED "Usage:") gsm <game-server-tag> <command>"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_YELLOW "Examples:")"
  echo -e "  $(_c LIGHT_GREEN "gsm") $(_c WHITE "cs2") $(_c LIGHT_GREEN "start")"
  echo -e "  $(_c LIGHT_RED "gsm") $(_c WHITE "cs2") $(_c LIGHT_RED "stop")"
  echo -e "  $(_c LIGHT_YELLOW "gsm") $(_c WHITE "cs2") $(_c LIGHT_YELLOW "restart")"
  echo -e "  $(_c LIGHT_CYAN "gsm") $(_c WHITE "cs2") $(_c LIGHT_CYAN "status")"
  echo -e "  $(_c LIGHT_MAGENTA "gsm") $(_c WHITE "cs2") $(_c LIGHT_MAGENTA "console")"
  echo -e "  $(_c LIGHT_BLUE "gsm") $(_c WHITE "cs2") $(_c LIGHT_BLUE "details")"


  exit 1
fi

docker exec -it --user linuxgsm linuxgsm-${game_server_name} ./${game_server_name}server ${*:2}
