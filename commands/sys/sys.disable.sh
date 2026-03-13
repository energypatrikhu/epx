_help() {
  echo -e "[$(_c LIGHT_BLUE "SYS - Disable Service")] Usage: $(_c LIGHT_YELLOW "sys.disable <service_name>")"
  echo -e "[$(_c LIGHT_BLUE "SYS - Disable Service")] Disable a system service from starting at boot using systemctl"
  echo -e "[$(_c LIGHT_BLUE "SYS - Disable Service")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - Disable Service")] Options:"
  echo -e "[$(_c LIGHT_BLUE "SYS - Disable Service")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "SYS - Disable Service")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - Disable Service")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "SYS - Disable Service")]   sys.disable nginx"
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
  echo -e "[$(_c LIGHT_BLUE "SYS - Disable Service")] Error: Service '${service_name}' not found."
  exit 1
fi

if ! systemctl is-enabled --quiet "${service_name}.service"; then
  echo -e "[$(_c LIGHT_BLUE "SYS - Disable Service")] Service '${service_name}' is already disabled."
  exit 0
fi

if systemctl disable "${service_name}.service"; then
  echo -e "[$(_c LIGHT_BLUE "SYS - Disable Service")] Service '${service_name}' disabled successfully."
else
  echo -e "[$(_c LIGHT_BLUE "SYS - Disable Service")] Failed to disable service '${service_name}'."
  exit 1
fi
