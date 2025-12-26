_cci smbpasswd

username="${1-}"
if [[ -z "${username}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Samba - Delete User")] $(_c LIGHT_YELLOW "Usage: smb.del <username>")"
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
