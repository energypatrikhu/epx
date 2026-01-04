_help() {
  echo -e "[$(_c LIGHT_BLUE "Python - Remove")] Usage: $(_c LIGHT_YELLOW "py.remove <package>")"
  echo -e "[$(_c LIGHT_BLUE "Python - Remove")] Remove Python packages via pip"
  echo -e "[$(_c LIGHT_BLUE "Python - Remove")]"
  echo -e "[$(_c LIGHT_BLUE "Python - Remove")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Python - Remove")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "Python - Remove")]"
  echo -e "[$(_c LIGHT_BLUE "Python - Remove")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Python - Remove")]   py.remove numpy"
  echo -e "[$(_c LIGHT_BLUE "Python - Remove")]   py.remove requests"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci pip

# check if no arguments are provided
if [[ -z $* ]]; then
  _help
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
