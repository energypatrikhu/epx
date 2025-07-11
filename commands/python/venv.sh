#!/bin/bash

py.venv() {
  # help message
  if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    __epx_echo "[$(_c LIGHT_BLUE "Python - VENV")] $(_c LIGHT_YELLOW "Usage: py.venv")"
    __epx_echo "[$(_c LIGHT_BLUE "Python - VENV")] $(_c LIGHT_YELLOW "Description: Activate, deactivate or create a Python virtual environment")"

    __epx_echo "[$(_c LIGHT_BLUE "Python - VENV")] $(_c LIGHT_YELLOW "Alias:")"
    __epx_echo "[$(_c LIGHT_BLUE "Python - VENV")] $(_c LIGHT_YELLOW "  py.env")"
    return 0
  fi

  # check if Python is installed
  if ! command -v python3 &>/dev/null; then
    __epx_echo "[$(_c LIGHT_BLUE "Python - VENV")] $(_c LIGHT_RED "Python is not installed")"
    return 1
  fi

  # check if virtual environment is activated, then deactivate
  if [ -n "$VIRTUAL_ENV" ]; then
    __epx_echo "[$(_c LIGHT_BLUE "Python - VENV")] Deactivating virtual environment"
    deactivate
    return 1
  fi

  # check if virtual environment exists, if not create it, then activate
  if [ ! -d .venv ]; then
    __epx_echo "[$(_c LIGHT_BLUE "Python - VENV")] Creating virtual environment"
    python3 -m venv .venv

    # check if virtual environment is created
    if [ ! -d .venv ]; then
      __epx_echo "[$(_c LIGHT_BLUE "Python - VENV")] $(_c LIGHT_RED "Failed to create virtual environment")"
      return 1
    fi

    # activate virtual environment
    __epx_echo "[$(_c LIGHT_BLUE "Python - VENV")] Activating virtual environment"
    source .venv/bin/activate
    return 0
  fi

  # activate virtual environment
  __epx_echo "[$(_c LIGHT_BLUE "Python - VENV")] Activating virtual environment"
  source .venv/bin/activate
}

py.env() {
  py.venv "$@"
}

# Auto enable virtual environment activation in the current shell if exists
if [ -d .venv ]; then
  if [ -z "$VIRTUAL_ENV" ]; then
    __epx_echo "[$(_c LIGHT_BLUE "Python - VENV")] Auto activating virtual environment"
    source .venv/bin/activate
  fi
fi
