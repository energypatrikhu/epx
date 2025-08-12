source "${EPX_HOME}/helpers/header.sh"

source "${EPX_HOME}/helpers/check-command-installed.sh"
_cci python3

source "${EPX_HOME}/helpers/colorize.sh"
source "${EPX_HOME}/helpers/colors.sh"

# help message
if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] $(_c LIGHT_YELLOW "Usage: py.venv")"
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] $(_c LIGHT_YELLOW "Description: Activate, deactivate or create a Python virtual environment")"

  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] $(_c LIGHT_YELLOW "Alias:")"
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] $(_c LIGHT_YELLOW "  py.env")"
  exit 0
fi

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
echo -e "[$(_c LIGHT_BLUE "Python - VENV")] Run $(_c LIGHT_YELLOW "source .venv/bin/activate")"
