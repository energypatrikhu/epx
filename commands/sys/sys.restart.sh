_help() {
  echo -e "[$(_c LIGHT_BLUE "SYS - Restart Service")] Usage: $(_c LIGHT_YELLOW "sys.restart <service_name>")"
  echo -e "[$(_c LIGHT_BLUE "SYS - Restart Service")] Restart a system service using systemctl"
  echo -e "[$(_c LIGHT_BLUE "SYS - Restart Service")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - Restart Service")] Options:"
  echo -e "[$(_c LIGHT_BLUE "SYS - Restart Service")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "SYS - Restart Service")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - Restart Service")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "SYS - Restart Service")]   sys.restart nginx"
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

_cci_pkg systemd:systemd

if [[ -z "${1-}" ]]; then
  _help
  exit 1
fi

service_name="${1%.service}"

if ! systemctl list-units --type=service --all --no-legend --plain | awk '{print $1}' | grep -Fxq "${service_name}.service"; then
  echo -e "[$(_c LIGHT_BLUE "SYS - Restart Service")] Error: Service '${service_name}' not found."
  exit 1
fi

if systemctl restart "${service_name}.service"; then
  echo -e "[$(_c LIGHT_BLUE "SYS - Restart Service")] Service '${service_name}' restarted successfully."
else
  echo -e "[$(_c LIGHT_BLUE "SYS - Restart Service")] Failed to restart service '${service_name}'."
  exit 1
fi
