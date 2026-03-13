_help() {
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Kill Session")] Usage: $(_c LIGHT_YELLOW "screen.kill <session_name|id>")"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Kill Session")] Kill (remove) an existing GNU Screen session"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Kill Session")]"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Kill Session")] Options:"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Kill Session")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Kill Session")]"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Kill Session")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Kill Session")]   screen.kill mysession"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Kill Session")]   screen.kill 12345"
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
if ! screen -list | grep -E "[[:space:]](${session}|\.${session})[[:space:]]" >/dev/null; then
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Kill Session")] Error: Session '${session}' does not exist."
  exit 1
fi

# Attempt to kill the session
if screen -S "${session}" -X quit; then
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Kill Session")] Session '${session}' killed."
else
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Kill Session")] Failed to kill screen session '${session}'."
  exit 1
fi
