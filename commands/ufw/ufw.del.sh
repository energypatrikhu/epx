_help() {
  echo -e "[$(_c LIGHT_BLUE "UFW - Delete Rule")] Usage: $(_c LIGHT_YELLOW "ufw.del <rule_number> / port <port>")"
  echo -e "[$(_c LIGHT_BLUE "UFW - Delete Rule")] Delete a rule from UFW (Uncomplicated Firewall)"
  echo -e "[$(_c LIGHT_BLUE "UFW - Delete Rule")]"
  echo -e "[$(_c LIGHT_BLUE "UFW - Delete Rule")] Options:"
  echo -e "[$(_c LIGHT_BLUE "UFW - Delete Rule")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "UFW - Delete Rule")]"
  echo -e "[$(_c LIGHT_BLUE "UFW - Delete Rule")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "UFW - Delete Rule")]   ufw.del 1"
  echo -e "[$(_c LIGHT_BLUE "UFW - Delete Rule")]   ufw.del port 80"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "UFW - Delete Rule")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci ufw

if [[ -z "${1-}" ]]; then
  _help
  exit 1
fi

if [[ "${1-}" =~ ^[0-9]+$ ]]; then
  ufw delete "${1-}"
  exit
fi

# if "${1-}" is 'port'
if [[ "${1-}" == "port" ]]; then
  if [[ -z "${2-}" ]]; then
    _help
    exit 1
  fi

  ufw delete allow "${2-}"
fi
