#!/bin/bash

source "${EPX_HOME}/helpers/check-command-installed.sh"
_cci python3

source "${EPX_HOME}/helpers/colorize.sh"
source "${EPX_HOME}/helpers/colors.sh"

# help message
if [ "${1}" == "-h" ] || [ "${1}" == "--help" ]; then
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] $(_c LIGHT_YELLOW "Usage: py.venv")"
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] $(_c LIGHT_YELLOW "Description: Activate, deactivate or create a Python virtual environment")"

  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] $(_c LIGHT_YELLOW "Alias:")"
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] $(_c LIGHT_YELLOW "  py.env")"
  exit 0
fi

# check if virtual environment is activated, then deactivate
if [ -n "${VIRTUAL_ENV}" ]; then
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] Deactivating virtual environment"
  deactivate
  exit 1
fi

# check if virtual environment exists, if not create it, then activate
if [ ! -d .venv ]; then
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] Creating virtual environment"
  python3 -m venv .venv

  # check if virtual environment is created
  if [ ! -d .venv ]; then
    echo -e "[$(_c LIGHT_BLUE "Python - VENV")] $(_c LIGHT_RED "Failed to create virtual environment")"
    exit 1
  fi

  # activate virtual environment
  echo -e "[$(_c LIGHT_BLUE "Python - VENV")] Activating virtual environment"
  exec bash -i -c "source .venv/bin/activate"
  exit 0
fi

# activate virtual environment
echo -e "[$(_c LIGHT_BLUE "Python - VENV")] Activating virtual environment"
exec bash -i -c "source .venv/bin/activate"
