_help() {
  echo -e "[$(_c LIGHT_BLUE "SYS - Stop Service")] Usage: $(_c LIGHT_YELLOW "sys.stop <service_name>")"
  echo -e "[$(_c LIGHT_BLUE "SYS - Stop Service")] Stop a system service using systemctl"
  echo -e "[$(_c LIGHT_BLUE "SYS - Stop Service")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - Stop Service")] Options:"
  echo -e "[$(_c LIGHT_BLUE "SYS - Stop Service")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "SYS - Stop Service")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - Stop Service")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "SYS - Stop Service")]   sys.stop nginx"
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

_cci_pkg systemd:systemctl

if [[ -z "${1-}" ]]; then
  _help
  exit 1
fi

service_name="${1%.service}"

if ! systemctl list-units --type=service --all --no-legend --plain | awk '{print $1}' | grep -Fxq "${service_name}.service"; then
  echo -e "[$(_c LIGHT_BLUE "SYS - Stop Service")] Error: Service '${service_name}' not found."
  exit 1
fi

if ! systemctl is-active --quiet "${service_name}.service"; then
  echo -e "[$(_c LIGHT_BLUE "SYS - Stop Service")] Service '${service_name}' is not running."
  exit 0
fi

if systemctl stop "${service_name}.service"; then
  echo -e "[$(_c LIGHT_BLUE "SYS - Stop Service")] Service '${service_name}' stopped successfully."
else
  echo -e "[$(_c LIGHT_BLUE "SYS - Stop Service")] Failed to stop service '${service_name}'."
  exit 1
fi
