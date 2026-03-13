_help() {
  echo -e "[$(_c LIGHT_BLUE "SYS - Status")] Usage: $(_c LIGHT_YELLOW "sys.status <service_name>")"
  echo -e "[$(_c LIGHT_BLUE "SYS - Status")] Show the status of a system service using systemctl"
  echo -e "[$(_c LIGHT_BLUE "SYS - Status")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - Status")] Options:"
  echo -e "[$(_c LIGHT_BLUE "SYS - Status")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "SYS - Status")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - Status")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "SYS - Status")]   sys.status nginx"
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
  echo -e "[$(_c LIGHT_BLUE "SYS - Status")] Error: Service '${service_name}' not found."
  exit 1
fi

systemctl status "${service_name}.service"
status_code=$?

if [[ $status_code -eq 0 ]]; then
  echo -e "[$(_c LIGHT_BLUE "SYS - Status")] Service '${service_name}' is running."
else
  echo -e "[$(_c LIGHT_BLUE "SYS - Status")] Service '${service_name}' is not running or failed."
fi

exit $status_code
