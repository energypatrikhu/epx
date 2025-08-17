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
