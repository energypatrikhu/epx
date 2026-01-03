_help() {
  echo -e "[$(_c LIGHT_BLUE "Python - Install")] Usage: $(_c LIGHT_YELLOW "py.install [packages...]")"
  echo -e "[$(_c LIGHT_BLUE "Python - Install")] Install Python packages via pip"
  echo -e "[$(_c LIGHT_BLUE "Python - Install")]"
  echo -e "[$(_c LIGHT_BLUE "Python - Install")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Python - Install")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "Python - Install")]"
  echo -e "[$(_c LIGHT_BLUE "Python - Install")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Python - Install")]   py.install numpy pandas"
  echo -e "[$(_c LIGHT_BLUE "Python - Install")]   py.install requests"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "Python - Install")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg python3:python3-minimal

# if no arguments are provided, install from requirements.txt
if [[ -z $* ]]; then
  # check if requirements.txt exists
  if [[ ! -f requirements.txt ]]; then
    echo -e "[$(_c LIGHT_BLUE "Python - Install")] $(_c LIGHT_YELLOW "requirements.txt") $(_c LIGHT_RED "not found")"
    exit 1
  fi

  # install dependencies
  echo -e "[$(_c LIGHT_BLUE "Python - Install")] Installing dependencies"
  pip install -r requirements.txt
  exit 0
fi

# install package
packages=$(printf "%s, " "${@}" | sed 's/, $//')
echo -e "[$(_c LIGHT_BLUE "Python - Install")] Installing $(_c LIGHT_YELLOW "${packages}")"
pip install "${@}"

# check if installation was successful, then add to requirements.txt, line by line
if [[ $? -eq 0 ]]; then
  for package in "${@}"; do
    echo "${package}" >>requirements.txt
  done
fi
