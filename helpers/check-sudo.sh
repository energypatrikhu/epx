_check_sudo() {
  if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root."
    exit 1
  fi
}
