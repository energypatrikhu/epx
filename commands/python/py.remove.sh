_cci pip# check if no arguments are provided
if [[ -z "${1-}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Python - Remove")] $(_c LIGHT_YELLOW "Usage: py.remove <package>")"

  echo -e "[$(_c LIGHT_BLUE "Python - Remove")] $(_c LIGHT_YELLOW "Alias:")"
  echo -e "[$(_c LIGHT_BLUE "Python - Remove")] $(_c LIGHT_YELLOW "  py.rm <package>")"
  echo -e "[$(_c LIGHT_BLUE "Python - Remove")] $(_c LIGHT_YELLOW "  py.uninstall <package>")"
  exit 1
fi

# remove package
packages=$(printf "%s, " "${@}" | sed 's/, $//')
echo -e "[$(_c LIGHT_BLUE "Python - Remove")] Removing $(_c LIGHT_YELLOW "${packages}")"
pip uninstall "${@}"

# check if removal was successful, then remove from requirements.txt, line by line
if [[ $? -eq 0 ]]; then
  for package in "${@}"; do
    sed -i "/${package}/d" requirements.txt
  done
fi
