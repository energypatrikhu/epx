_help() {
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")] Usage: $(_c LIGHT_YELLOW "ufw.list")"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")] List all rules in UFW (Uncomplicated Firewall)"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")]"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")] Options:"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")]"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")]   ufw.list"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg ufw:ufw

ufw status numbered
