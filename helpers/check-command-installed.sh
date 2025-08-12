_cci() {
  local not_installed=()

  for cmd in "$@"; do
    if ! command -v "${cmd}" &> /dev/null; then
      not_installed+=("${cmd}")
    fi
  done

  if [[ ${#not_installed[@]} -ne 0 ]]; then
    echo "Error: The following commands are not installed: ${not_installed[*]}. Please install them to use this script."
    exit 1
  fi
}
