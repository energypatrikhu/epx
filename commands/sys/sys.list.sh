_help() {
  echo -e "[$(_c LIGHT_BLUE "SYS - List")] Usage: $(_c LIGHT_YELLOW "sys.list [--status <state>] [pattern]")"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")] List system services using systemctl"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")] Options:"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")]   -h, --help           Show this help message"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")]   --status <state>     Filter by service state (active, inactive, failed, etc)"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")]"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")]   sys.list"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")]   sys.list --status active"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")]   sys.list nginx"
  echo -e "[$(_c LIGHT_BLUE "SYS - List")]   sys.list --status failed ssh"
}

opt_help=false
filter_status=""
pattern=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      opt_help=true
      shift
      ;;
    --status)
      filter_status="$2"
      shift 2
      ;;
    *)
      pattern="$1"
      shift
      ;;
  esac
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg systemd:systemd

# List all services
services=$(systemctl list-units --type=service --all --no-legend --plain)

if [[ -n "$pattern" ]]; then
  services=$(echo "$services" | grep -i "$pattern")
fi

if [[ -n "$filter_status" ]]; then
  # Only match lines where the 4th column (state) matches the filter
  services=$(echo "$services" | awk -v s="$filter_status" '$4 == s')
fi

if [[ -z "$services" ]]; then
  echo -e "[$(_c LIGHT_BLUE "SYS - List")] No services found."
  exit 0
fi

echo -e "[$(_c LIGHT_BLUE "SYS - List")] Listing services:"
echo "$services" | awk '{printf "  %-40s %-10s %-10s %-10s %s\n", $1, $2, $3, $4, $5}'

exit 0
