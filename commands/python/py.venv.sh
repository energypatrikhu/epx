_help() {
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] Usage: $(_c LIGHT_YELLOW "py.venv")"
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] Activate, deactivate or create a Python virtual environment"
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")]"
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")]"
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")]   py.venv"
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

_cci_pkg python3:python3-minimal

# check if virtual environment is activated, then deactivate
if [[ -n "${VIRTUAL_ENV-}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] To deactivate virtual environment"
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] Run $(_c LIGHT_YELLOW "deactivate")"
  exit 1
fi

# check if virtual environment exists, if not create it, then activate
if [[ ! -d .venv ]]; then
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] Creating virtual environment"
  python3 -m venv .venv

  # check if virtual environment is created
  if [[ ! -d .venv ]]; then
    echo -e "[$(_c LIGHT_BLUE "Python - VENV")] $(_c LIGHT_RED "Failed to create virtual environment")"
    exit 1
  fi
fi

# activate virtual environment
echo -e "[$(_c LIGHT_BLUE "Python - VENV")] To activate virtual environment"
if [[ "${SHELL}" == *"fish" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] Run $(_c LIGHT_YELLOW "source .venv/bin/activate.fish")"
else
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] Run $(_c LIGHT_YELLOW "source .venv/bin/activate")"
fi
