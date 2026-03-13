_help() {
  echo -e "[$(_c LIGHT_BLUE "SYS - Start Service")] Usage: $(_c LIGHT_YELLOW "sys.start <service_name>")"
  echo -e "[$(_c LIGHT_BLUE "SYS - Start Service")] Start a system service using systemctl"
  echo -e "[$(_c LIGHT_BLUE "SYS - Start Service")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - Start Service")] Options:"
  echo -e "[$(_c LIGHT_BLUE "SYS - Start Service")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "SYS - Start Service")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - Start Service")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "SYS - Start Service")]   sys.start nginx"
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
  echo -e "[$(_c LIGHT_BLUE "SYS - Start Service")] Error: Service '${service_name}' not found."
  exit 1
fi

if systemctl is-active --quiet "${service_name}.service"; then
  echo -e "[$(_c LIGHT_BLUE "SYS - Start Service")] Service '${service_name}' is already running."
  exit 0
fi

if systemctl start "${service_name}.service"; then
  echo -e "[$(_c LIGHT_BLUE "SYS - Start Service")] Service '${service_name}' started successfully."
else
  echo -e "[$(_c LIGHT_BLUE "SYS - Start Service")] Failed to start service '${service_name}'."
  exit 1
fi
