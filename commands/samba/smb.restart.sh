_help() {
  echo -e "[$(_c LIGHT_BLUE "Samba - Restart")] Usage: $(_c LIGHT_YELLOW "smb.restart")"
  echo -e "[$(_c LIGHT_BLUE "Samba - Restart")]"
  echo -e "[$(_c LIGHT_BLUE "Samba - Restart")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Samba - Restart")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "Samba - Restart")]"
  echo -e "[$(_c LIGHT_BLUE "Samba - Restart")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Samba - Restart")]   smb.restart"
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

_cci_pkg samba:samba-ad-dc

echo -e "[$(_c LIGHT_BLUE "Samba - Restart")] $(_c LIGHT_YELLOW "Restarting Samba service...")"

# Try systemctl first (most common on modern systems)
if command -v systemctl &> /dev/null; then
  if systemctl restart smbd 2>/dev/null || systemctl restart smb 2>/dev/null || systemctl restart samba 2>/dev/null; then
    echo -e "[$(_c LIGHT_BLUE "Samba - Restart")] $(_c LIGHT_GREEN "Samba service restarted using systemctl.")"
    exit 0
  fi
fi

# Try service command
if command -v service &> /dev/null; then
  if service smbd restart 2>/dev/null || service smb restart 2>/dev/null || service samba restart 2>/dev/null; then
    echo -e "[$(_c LIGHT_BLUE "Samba - Restart")] $(_c LIGHT_GREEN "Samba service restarted using service command.")"
    exit 0
  fi
fi

# Try /etc/init.d scripts
if [ -f /etc/init.d/smbd ]; then
  /etc/init.d/smbd restart
  echo -e "[$(_c LIGHT_BLUE "Samba - Restart")] $(_c LIGHT_GREEN "Samba service restarted using init.d script.")"
  exit 0
elif [ -f /etc/init.d/samba ]; then
  /etc/init.d/samba restart
  echo -e "[$(_c LIGHT_BLUE "Samba - Restart")] $(_c LIGHT_GREEN "Samba service restarted using init.d script.")"
  exit 0
elif [ -f /etc/init.d/smb ]; then
  /etc/init.d/smb restart
  echo -e "[$(_c LIGHT_BLUE "Samba - Restart")] $(_c LIGHT_GREEN "Samba service restarted using init.d script.")"
  exit 0
fi

# Try rc-service (OpenRC)
if command -v rc-service &> /dev/null; then
  if rc-service samba restart 2>/dev/null || rc-service smbd restart 2>/dev/null; then
    echo -e "[$(_c LIGHT_BLUE "Samba - Restart")] $(_c LIGHT_GREEN "Samba service restarted using rc-service.")"
    exit 0
  fi
fi

echo -e "[$(_c LIGHT_BLUE "Samba - Restart")] $(_c LIGHT_RED "Cannot restart Samba services: no supported service management system found.")"
echo -e "[$(_c LIGHT_BLUE "Samba - Restart")] $(_c LIGHT_YELLOW "Tried: systemctl, service, /etc/init.d, and rc-service")"
exit 1
