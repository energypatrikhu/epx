_help() {
  echo -e "[$(_c LIGHT_BLUE "UFW - Status")] Usage: $(_c LIGHT_YELLOW "ufw.status <[on|enable] | [off|disable]>")"
  echo -e "[$(_c LIGHT_BLUE "UFW - Status")] Show or change the status of UFW (Uncomplicated Firewall)"
  echo -e "[$(_c LIGHT_BLUE "UFW - Status")]"
  echo -e "[$(_c LIGHT_BLUE "UFW - Status")] Options:"
  echo -e "[$(_c LIGHT_BLUE "UFW - Status")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "UFW - Status")]"
  echo -e "[$(_c LIGHT_BLUE "UFW - Status")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "UFW - Status")]   ufw.status on"
  echo -e "[$(_c LIGHT_BLUE "UFW - Status")]   ufw.status off"
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
  ufw status
  exit
fi

case "${1,,}" in
  on|enable)
    ufw enable
    ;;
  off|disable)
    ufw disable
    ;;
  *)
    echo -e "[$(_c LIGHT_CYAN "UFW")] $(_c LIGHT_YELLOW "Usage: ufw.status <[on|enable] | [off|disable]>")"
    exit 1
    ;;
esac
