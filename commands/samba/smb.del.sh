_help() {
  echo -e "[$(_c LIGHT_BLUE "Samba - Delete User")] Usage: $(_c LIGHT_YELLOW "smb.del <username>")"
  echo -e "[$(_c LIGHT_BLUE "Samba - Delete User")] Delete a user from Samba"
  echo -e "[$(_c LIGHT_BLUE "Samba - Delete User")]"
  echo -e "[$(_c LIGHT_BLUE "Samba - Delete User")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Samba - Delete User")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "Samba - Delete User")]"
  echo -e "[$(_c LIGHT_BLUE "Samba - Delete User")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Samba - Delete User")]   smb.del username"
  echo -e "[$(_c LIGHT_BLUE "Samba - Delete User")]   smb.del anotheruser"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "Samba - Delete User")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg smbpasswd:samba-common-bin

username="${1-}"
if [[ -z "${username}" ]]; then
  _help
  exit 1
fi

# Remove from Samba
echo -e "[$(_c LIGHT_BLUE "Samba - Delete User")] $(_c LIGHT_YELLOW "Removing '${username}' from Samba...")"
if smbpasswd -x "${username}"; then
  echo -e "[$(_c LIGHT_BLUE "Samba - Delete User")] $(_c LIGHT_GREEN "Samba user '${username}' removed successfully")"
else
  echo -e "[$(_c LIGHT_BLUE "Samba - Delete User")] $(_c LIGHT_RED "Failed to remove Samba user '${username}'")"
  exit 1
fi

# Ask to remove system user
read -p "[$(_c LIGHT_BLUE "Samba - Delete User")] $(_c LIGHT_YELLOW "Remove system user '${username}' as well? (y/N): ")" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  if userdel "${username}"; then
    echo -e "[$(_c LIGHT_BLUE "Samba - Delete User")] $(_c LIGHT_GREEN "System user '${username}' removed successfully")"
  else
    echo -e "[$(_c LIGHT_BLUE "Samba - Delete User")] $(_c LIGHT_RED "Failed to remove system user '${username}'")"
  fi
else
  echo -e "[$(_c LIGHT_BLUE "Samba - Delete User")] $(_c LIGHT_YELLOW "System user '${username}' not removed")"
fi
