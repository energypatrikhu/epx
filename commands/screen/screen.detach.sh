_help() {
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Detach Session")] Usage: $(_c LIGHT_YELLOW "screen.detach <session_name|id>")"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Detach Session")] Detach an existing GNU Screen session"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Detach Session")]"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Detach Session")] Options:"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Detach Session")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Detach Session")]"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Detach Session")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Detach Session")]   screen.detach mysession"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Detach Session")]   screen.detach 12345"
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
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Detach Session")] Error: Session '${session}' does not exist."
  exit 1
fi

if screen -d "${session}"; then
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Detach Session")] Detached session '${session}'."
else
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Detach Session")] Failed to detach screen session '${session}'."
  exit 1
fi
