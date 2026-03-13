_help() {
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Create Session")] Usage: $(_c LIGHT_YELLOW "screen.create <session_name>")"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Create Session")] Create a new GNU Screen session"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Create Session")]"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Create Session")] Options:"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Create Session")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Create Session")]"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Create Session")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Create Session")]   screen.create mysession"
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

session_name="${1}"

# Check if session already exists
if screen -list | grep -q "[[:space:]]${session_name}[[:space:]]"; then
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Create Session")] Error: Session '${session_name}' already exists."
  exit 1
fi

if screen -dmS "${session_name}"; then
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Create Session")] Screen session '${session_name}' created successfully."
else
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Create Session")] Failed to create screen session '${session_name}'."
  exit 1
fi
