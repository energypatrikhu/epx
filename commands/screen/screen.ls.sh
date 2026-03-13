_help() {
  echo -e "[$(_c LIGHT_BLUE "SCREEN - List Sessions")] Usage: $(_c LIGHT_YELLOW "screen.ls")"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - List Sessions")] List all running GNU Screen sessions"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - List Sessions")]"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - List Sessions")] Options:"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - List Sessions")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - List Sessions")]"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - List Sessions")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - List Sessions")]   screen.ls"
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

_cci_pkg screen:screen

# List all screen sessions
if ! screen -list | grep -q "No Sockets found"; then
  echo -e "[$(_c LIGHT_BLUE "SCREEN - List Sessions")] Active sessions:"
  # Print sessions, skipping header/footer lines
  screen -list | awk '/Attached|Detached/ {print "  - " $1 " (" $2 ")"}'
else
  echo -e "[$(_c LIGHT_BLUE "SCREEN - List Sessions")] No active screen sessions found."
fi
