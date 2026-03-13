_help() {
  echo -e "[$(_c LIGHT_BLUE "SYS - Remove Service")] Usage: $(_c LIGHT_YELLOW "sys.remove <service_name>")"
  echo -e "[$(_c LIGHT_BLUE "SYS - Remove Service")] Remove a system service using systemctl"
  echo -e "[$(_c LIGHT_BLUE "SYS - Remove Service")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - Remove Service")] Options:"
  echo -e "[$(_c LIGHT_BLUE "SYS - Remove Service")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "SYS - Remove Service")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - Remove Service")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "SYS - Remove Service")]   sys.remove nginx"
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

if [[ -z "${1-}" ]]; then
  _help
  exit 1
fi

service_name="${1%.service}"

if ! systemctl list-units --type=service --all --no-legend --plain | awk '{print $1}' | grep -Fxq "${service_name}.service"; then
  echo -e "[$(_c LIGHT_RED "SYS - Remove Service")] Error: Service '${service_name}' not found."
  exit 1
fi

if systemctl is-active --quiet "${service_name}.service"; then
  systemctl stop "${service_name}.service"
fi

if ! systemctl disable "${service_name}.service"; then
  echo -e "[$(_c LIGHT_RED "SYS - Remove Service")] Failed to disable service '${service_name}'."
  exit 1
fi

if ! systemctl reset-failed "${service_name}.service"; then
  echo -e "[$(_c LIGHT_RED "SYS - Remove Service")] Failed to reset-failed for '${service_name}'."
  exit 1
fi

service_file="/etc/systemd/system/${service_name}.service"
if [[ -f "${service_file}" ]]; then
  if ! rm -f "${service_file}"; then
    echo -e "[$(_c LIGHT_RED "SYS - Remove Service")] Failed to remove service file for '${service_name}'."
    exit 1
  fi
  systemctl daemon-reload
fi

echo -e "[$(_c LIGHT_GREEN "SYS - Remove Service")] Service '${service_name}' removed successfully."
