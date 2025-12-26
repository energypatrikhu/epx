_cci net

opt_short=false
if [[ "${1-}" == --short ]] || [[ "${1-}" == -s ]] || [[ "${1-}" == "short" ]]; then
  opt_short=true
fi

echo -e "[$(_c LIGHT_BLUE "Samba - List Shares")] $(_c LIGHT_YELLOW "Listing available Samba shares...")"
echo -e "[$(_c LIGHT_BLUE "Samba - List Shares")] $(_c LIGHT_CYAN "Note: Use smb.list <short/--short/-s> to show only share names")"

__fallback(){
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
}

conf_arg="list"
if [[ "${opt_short}" == true ]]; then
  conf_arg="listshares"
fi

if ! net conf "${conf_arg}"; then
  __fallback
fi
