#!/bin/bash

source "${EPX_HOME}/helpers/colorize.sh"
source "${EPX_HOME}/helpers/colors.sh"

# Auto enable virtual environment activation in the current shell if exists
if [[ -d .venv ]]; then
  if [[ -z "${VIRTUAL_ENV}" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Python - VENV")] Auto activating virtual environment"
    source .venv/bin/activate
  fi
fi
