_help() {
  echo -e "[$(_c LIGHT_BLUE "Samba - List Shares")] Usage: $(_c LIGHT_YELLOW "smb.list <short/--short/-s>")"
  echo -e "[$(_c LIGHT_BLUE "Samba - List Shares")] List available Samba shares"
  echo -e "[$(_c LIGHT_BLUE "Samba - List Shares")]"
  echo -e "[$(_c LIGHT_BLUE "Samba - List Shares")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Samba - List Shares")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "Samba - List Shares")]   -s, --short    Show only share names"
  echo -e "[$(_c LIGHT_BLUE "Samba - List Shares")]"
  echo -e "[$(_c LIGHT_BLUE "Samba - List Shares")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Samba - List Shares")]   smb.list"
  echo -e "[$(_c LIGHT_BLUE "Samba - List Shares")]   smb.list --short"
}

opt_help=false
opt_short=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    elif [[ "${arg}" =~ ^-*(s|short)$ ]]; then
      opt_short=true
    else
      echo -e "[$(_c LIGHT_BLUE "Samba - List Shares")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci net

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
if [[ "${opt_short}" == "true" ]]; then
  conf_arg="listshares"
fi

if ! net conf "${conf_arg}"; then
  __fallback
fi
