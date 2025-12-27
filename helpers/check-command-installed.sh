# Check if commands are installed on the system
#
# This function verifies whether one or more commands are available in the system PATH.
# If any commands are not found, it displays an error message listing all missing commands
# and exits the script with status code 1.
#
# Usage:
#   _cci command1 [command2 ...]
#
# Arguments:
#   $@    - One or more command names to check
#
# Returns:
#   0     - All specified commands are installed
#   1     - One or more commands are not installed (exits script)
#
# Example:
#   _cci git curl jq
#   # Checks if git, curl, and jq are installed
#
# Note:
#   This function will terminate the script if any command is missing.
_cci() {
  local not_installed=()

  for cmd in "$@"; do
    if ! command -v "${cmd}" &> /dev/null; then
      not_installed+=("${cmd}")
    fi
  done

  if [[ ${#not_installed[@]} -ne 0 ]]; then
    echo -e "$(_c LIGHT_RED "Error"): The following commands are not installed:"
    for cmd in "${not_installed[@]}"; do
      echo -e "  - $(_c LIGHT_YELLOW "${cmd}")"
    done
    exit 1
  fi
}
