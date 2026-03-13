_help() {
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Execute/Attach")] Usage: $(_c LIGHT_YELLOW "screen.execute <session_name|id> [commands...]")"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Execute/Attach")] Attach to an existing GNU Screen session, or execute commands in it"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Execute/Attach")]"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Execute/Attach")] Options:"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Execute/Attach")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Execute/Attach")]"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Execute/Attach")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Execute/Attach")]   screen.execute mysession"
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Execute/Attach")]   screen.execute 12345 ls -l /"
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
shift

# Check if session exists (by name or id)
if ! screen -list | grep -E "[[:space:]]${session}[[:space:]]|\.${session}[[:space:]]" >/dev/null; then
  echo -e "[$(_c LIGHT_BLUE "SCREEN - Execute/Attach")] Error: Session '${session}' does not exist."
  exit 1
fi

if [[ $# -eq 0 ]]; then
  # No commands, just attach
  if screen -r "${session}"; then
    :
  else
    echo -e "[$(_c LIGHT_BLUE "SCREEN - Execute/Attach")] Failed to attach to screen session '${session}'."
    exit 1
  fi
else
  # Send commands to the session
  cmd="$*"
  # Escape double quotes and backslashes for screen
  cmd_escaped="${cmd//\\/\\\\}"
  cmd_escaped="${cmd_escaped//\"/\\\"}"
  # Send the command followed by Enter
  if screen -S "${session}" -X stuff "${cmd_escaped}"$'\n'; then
    echo -e "[$(_c LIGHT_BLUE "SCREEN - Execute/Attach")] Sent command to session '${session}': $cmd"
  else
    echo -e "[$(_c LIGHT_BLUE "SCREEN - Execute/Attach")] Failed to send command to session '${session}'."
    exit 1
  fi
fi
