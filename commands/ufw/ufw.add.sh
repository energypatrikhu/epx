_help() {
  echo -e "[$(_c LIGHT_BLUE "UFW - Add Rule")] Usage: $(_c LIGHT_YELLOW "ufw.add <port>")"
  echo -e "[$(_c LIGHT_BLUE "UFW - Add Rule")] Add a rule to UFW (Uncomplicated Firewall)"
  echo -e "[$(_c LIGHT_BLUE "UFW - Add Rule")]"
  echo -e "[$(_c LIGHT_BLUE "UFW - Add Rule")] Options:"
  echo -e "[$(_c LIGHT_BLUE "UFW - Add Rule")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "UFW - Add Rule")]"
  echo -e "[$(_c LIGHT_BLUE "UFW - Add Rule")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "UFW - Add Rule")]   ufw.add 80"
  echo -e "[$(_c LIGHT_BLUE "UFW - Add Rule")]   ufw.add 443"
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

_cci_pkg ufw:ufw

if [[ -z "${1-}" ]]; then
  _help
  exit 1
fi

if [[ "${1-}" =~ ^[0-9]+$ ]]; then
  ufw allow "${1-}"
  exit
fi

echo -e "[$(_c LIGHT_CYAN "UFW")] $(_c LIGHT_RED "Error:") $(_c LIGHT_YELLOW "Invalid argument: ${1}")"
