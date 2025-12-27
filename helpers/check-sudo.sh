# Check if the script is running with root privileges.
#
# This function verifies that the effective user ID (EUID) is 0, which indicates
# root/superuser privileges. If the script is not running as root, it prints an
# error message and exits with status code 1.
#
# Globals:
#   EUID - The effective user ID of the current user
#
# Arguments:
#   None
#
# Returns:
#   Exits with status 1 if not running as root
#
# Example:
#   _check_sudo
_check_sudo() {
  if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root."
    exit 1
  fi
}
