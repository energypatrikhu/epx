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
    else
      opt_status="${arg,,}"
      if [[ ! "${opt_status}" =~ ^(active|inactive|failed|activating|deactivating)$ ]]; then
        echo -e "[$(_c LIGHT_RED "SYS - List")] Error: Invalid status filter '${arg}'. Valid options are: active, inactive, failed, activating, deactivating."
        exit 1
      fi
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg systemctl:systemd

# List all services
services=$(systemctl list-units --type=service --all --no-legend --plain)

if [[ -n "$opt_status" ]]; then
  # Only match lines where the 4th column (state) matches the filter
  services=$(echo "$services" | awk -v s="$opt_status" '$4 == s')
fi

if [[ -z "$services" ]]; then
  echo -e "[$(_c LIGHT_BLUE "SYS - List")] No services found."
  exit 0
fi

echo -e "[$(_c LIGHT_BLUE "SYS - List")] Listing services:"
echo "$services" | awk '{printf "  %-40s %-10s %-10s %-10s %s\n", $1, $2, $3, $4, $5}'

exit 0
