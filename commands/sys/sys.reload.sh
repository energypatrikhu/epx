_help() {
  echo -e "[$(_c LIGHT_BLUE "SYS - Reload")] Usage: $(_c LIGHT_YELLOW "sys.reload")"
  echo -e "[$(_c LIGHT_BLUE "SYS - Reload")] Reload the systemd manager configuration (systemctl daemon-reload)"
  echo -e "[$(_c LIGHT_BLUE "SYS - Reload")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - Reload")] Options:"
  echo -e "[$(_c LIGHT_BLUE "SYS - Reload")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "SYS - Reload")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - Reload")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "SYS - Reload")]   sys.reload"
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

_cci_pkg systemctl:systemd

if ! command -v systemctl >/dev/null 2>&1; then
  echo -e "[$(_c LIGHT_RED "SYS - Reload")] Error: systemctl not found."
  exit 1
fi

if ! systemctl daemon-reload; then
  echo -e "[$(_c LIGHT_RED "SYS - Reload")] Error: Failed to reload systemd manager configuration."
  exit 1
fi

echo -e "[$(_c LIGHT_GREEN "SYS - Reload")] Systemd manager configuration reloaded successfully."
