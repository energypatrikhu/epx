_help() {
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")] Usage: $(_c LIGHT_YELLOW "ufw.search") <search_term>"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")] Search for specific rules in UFW (Uncomplicated Firewall) based on criteria"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")]"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")] Options:"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")]"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")]   ufw.search 80"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")]   ufw.search 443/tcp"
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

if [[ "$#" -eq 0 ]]; then
  _help
  exit 1
fi

ufw status numbered | grep --color=always -i "${1:-}"
