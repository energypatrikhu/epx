#!/bin/bash

py.venv() {
  # check if Python is installed
  if ! command -v python3 &>/dev/null; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Python - VENV")] $(_c LIGHT_RED "Python is not installed")"
    return 1
  fi

  # check if virtual environment is activated, then deactivate
  if [ -n "$VIRTUAL_ENV" ]; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Python - VENV")] Deactivating virtual environment"
    deactivate
    return 1
  fi

  # check if virtual environment exists
  if [ ! -d .venv ]; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Python - VENV")] $(_c LIGHT_RED "Virtual environment does not exist")"
    return 1
  fi

  # activate virtual environment
  printf "%s\n" "[$(_c LIGHT_BLUE "Python - VENV")] Activating virtual environment"
  source .venv/bin/activate
}
