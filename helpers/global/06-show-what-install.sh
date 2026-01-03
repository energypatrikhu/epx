# Check if commands are installed and suggest packages to install
#
# This function verifies whether one or more commands are available in the system PATH.
# If any commands are not found, it displays an error message listing all missing commands
# along with their respective packages and exits the script with status code 1.
#
# Usage:
#   _cci_pkg command1:package1 [command2:package2 ...]
#
# Arguments:
#   $@    - One or more "command:package" pairs (colon-separated)
#
# Returns:
#   0     - All specified commands are installed
#   1     - One or more commands are not installed (exits script)
#
# Example:
#   _cci_pkg git:git curl:curl jq:jq
#   # Checks if git, curl, and jq are installed and shows their package names
#
# Note:
#   This function will terminate the script if any command is missing.
_cci_pkg() {
  local not_installed=()

  for item in "$@"; do
    local cmd="${item%%:*}"
    local pkg="${item##*:}"

    if ! command -v "${cmd}" &> /dev/null; then
      not_installed+=("${cmd}:${pkg}")
    fi
  done

  if [[ ${#not_installed[@]} -ne 0 ]]; then
    echo -e "$(_c LIGHT_RED "Error"): The following commands are not installed:"
    for item in "${not_installed[@]}"; do
      local cmd="${item%%:*}"
      local pkg="${item##*:}"
      echo -e "  - $(_c LIGHT_YELLOW "${cmd}") (package: $(_c LIGHT_CYAN "${pkg}"))"
    done
    exit 1
  fi
}
