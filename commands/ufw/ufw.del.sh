_cci ufw

if [[ -z "${1-}" ]]; then
  echo -e "[$(_c LIGHT_CYAN "UFW")] $(_c LIGHT_YELLOW "Usage: ufw.del <rule_number> / port <port>")"
  exit 1
fi

if [[ "${1-}" =~ ^[0-9]+$ ]]; then
  ufw delete "${1-}"
  exit
fi

# if "${1-}" is 'port'
if [[ "${1-}" == "port" ]]; then
  if [[ -z "${2-}" ]]; then
    echo -e "[$(_c LIGHT_CYAN "UFW")] $(_c LIGHT_YELLOW "Usage: ufw.del port <port>")"
    exit 1
  fi

  ufw delete allow "${2-}"
  exit
fi
