_help() {
  echo -e "[$(_c LIGHT_BLUE "Samba - Add User")] Usage: $(_c LIGHT_YELLOW "smb.add <username>")"
  echo -e "[$(_c LIGHT_BLUE "Samba - Add User")] Add a user to Samba"
  echo -e "[$(_c LIGHT_BLUE "Samba - Add User")]"
  echo -e "[$(_c LIGHT_BLUE "Samba - Add User")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Samba - Add User")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "Samba - Add User")]"
  echo -e "[$(_c LIGHT_BLUE "Samba - Add User")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Samba - Add User")]   smb.add username"
  echo -e "[$(_c LIGHT_BLUE "Samba - Add User")]   smb.add anotheruser"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "IT - Barcode")] $(_c LIGHT_RED "Unknown option:") ${arg}"
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

# Check if system user exists
if ! id "${username}" > /dev/null 2>&1; then
  echo -e "[$(_c LIGHT_BLUE "Samba - Add User")] $(_c LIGHT_YELLOW "System user '${username}' does not exist. Creating...")"
  if ! useradd -M -s /sbin/nologin "${username}"; then
    echo -e "[$(_c LIGHT_BLUE "Samba - Add User")] $(_c LIGHT_RED "Failed to create system user '${username}'")"
    exit 1
  fi
  echo -e "[$(_c LIGHT_BLUE "Samba - Add User")] $(_c LIGHT_GREEN "System user '${username}' created successfully")"
else
  echo -e "[$(_c LIGHT_BLUE "Samba - Add User")] $(_c LIGHT_YELLOW "System user '${username}' already exists")"
fi

# Add to Samba
echo -e "[$(_c LIGHT_BLUE "Samba - Add User")] $(_c LIGHT_YELLOW "Adding '${username}' to Samba. You will be prompted for a password.")"
if smbpasswd -a "${username}"; then
  echo -e "[$(_c LIGHT_BLUE "Samba - Add User")] $(_c LIGHT_GREEN "Samba user '${username}' added successfully")"
else
  echo -e "[$(_c LIGHT_BLUE "Samba - Add User")] $(_c LIGHT_RED "Failed to add Samba user '${username}'")"
  exit 1
fi
