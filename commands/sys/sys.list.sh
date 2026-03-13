_help() {
  echo -e "[$(_c LIGHT_BLUE "SYS - List")] Usage: $(_c LIGHT_YELLOW "sys.list [<state>]")"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")] List system services using systemctl"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")] Options:"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")]   -h, --help           Show this help message"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")]   sys.list"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")]   sys.list active"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")]   sys.list failed"
}

opt_help=false
opt_status=""
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    fi
  else
    opt_status="${arg,,}"
    if [[ -n "${opt_status}" && ! "${opt_status}" =~ ^(active|inactive|failed|activating|deactivating)$ ]]; then
      echo -e "[$(_c LIGHT_RED "SYS - List")] Error: Invalid status filter '${arg}'. Valid options are: active, inactive, failed, activating, deactivating."
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg systemctl:systemd

if [[ -n "$opt_status" ]]; then
  # Filter services by the specified status
  systemctl list-units --type=service --all --plain --state="$opt_status"
else
  # List all services without filtering by status
  systemctl list-units --type=service --all --plain
fi
