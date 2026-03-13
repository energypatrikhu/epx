_help() {
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Attach Session")] Usage: $(_c LIGHT_YELLOW "screen.attach <session_name|id>")"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Attach Session")] Attach to an existing GNU Screen session"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Attach Session")]"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Attach Session")] Options:"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Attach Session")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Attach Session")]"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Attach Session")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Attach Session")]   screen.attach mysession"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Attach Session")]   screen.attach 12345"
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

if [[ -z "${1-}" ]]; then
  _help
  exit 1
fi

session="${1}"

# Check if session exists (by name or id)
if ! screen -list | grep -E "[[:space:]]${session}[[:space:]]|\.${session}[[:space:]]" >/dev/null; then
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Attach Session")] Error: Session '${session}' does not exist."
  exit 1
fi

if screen -r "${session}"; then
  :
else
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Attach Session")] Failed to attach to screen session '${session}'."
  exit 1
fi
