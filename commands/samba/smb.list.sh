_cci net

echo -e "[$(_c LIGHT_BLUE "Samba - List Shares")] $(_c LIGHT_YELLOW "Listing available Samba shares...")"

if ! net conf listshares; then
  _cci grep sed

  echo -e "[$(_c LIGHT_BLUE "Samba - List Shares")] $(_c LIGHT_YELLOW "Falling back to parsing configuration file...")"
  if [[ ! -f /etc/samba/smb.conf ]]; then
    echo -e "[$(_c LIGHT_BLUE "Samba - List Shares")] $(_c LIGHT_RED "Samba configuration file not found at /etc/samba/smb.conf")"
    exit 1
  fi

  shares=$(grep '^\[' /etc/samba/smb.conf | grep -v '^\[global\]' | sed 's/\[//' | sed 's/\]//' | sort)

  if [[ -z "${shares}" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Samba - List Shares")] $(_c LIGHT_YELLOW "No shares found in configuration")"
  else
    echo -e "[$(_c LIGHT_BLUE "Samba - List Shares")] $(_c LIGHT_GREEN "Available shares:")"
    echo "${shares}"
  fi
fi
