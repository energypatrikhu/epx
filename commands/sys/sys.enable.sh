_help() {
  echo -e "[$(_c LIGHT_BLUE "SYS - Enable Service")] Usage: $(_c LIGHT_YELLOW "sys.enable <service_name>")"
  echo -e "[$(_c LIGHT_BLUE "SYS - Enable Service")] Enable a system service to start at boot using systemctl"
  echo -e "[$(_c LIGHT_BLUE "SYS - Enable Service")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - Enable Service")] Options:"
  echo -e "[$(_c LIGHT_BLUE "SYS - Enable Service")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "SYS - Enable Service")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - Enable Service")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "SYS - Enable Service")]   sys.enable nginx"
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
  echo -e "[$(_c LIGHT_RED "SYS - Enable Service")] Error: Service '${service_name}' not found."
  exit 1
fi

# Check if already enabled
if systemctl is-enabled --quiet "${service_name}.service"; then
  echo -e "[$(_c LIGHT_BLUE "SYS - Enable Service")] Service '${service_name}' is already enabled."
  exit 0
fi

# Try to enable the service
if systemctl enable "${service_name}.service"; then
  echo -e "[$(_c LIGHT_GREEN "SYS - Enable Service")] Service '${service_name}' enabled successfully."
else
  echo -e "[$(_c LIGHT_RED "SYS - Enable Service")] Failed to enable service '${service_name}'."
  exit 1
fi
