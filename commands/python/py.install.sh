#!/bin/bash

py.install() {
  # check if Python is installed
  if ! command -v python3 &>/dev/null; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Python - Install")] $(_c LIGHT_RED "Python is not installed")"
    return 1
  fi

  # if no arguments are provided, install from requirements.txt
  if [ -z "$1" ]; then
    # check if requirements.txt exists
    if [ ! -f requirements.txt ]; then
      printf "%s\n" "[$(_c LIGHT_BLUE "Python - Install")] $(_c LIGHT_YELLOW "requirements.txt") $(_c LIGHT_RED "not found")"
      return 1
    fi

    # install dependencies
    printf "%s\n" "[$(_c LIGHT_BLUE "Python - Install")] Installing dependencies"
    pip install -r requirements.txt
    return 0
  fi

  # install package
  packages=$(printf "%s, " "$@" | sed 's/, $//')
  printf "%s\n" "[$(_c LIGHT_BLUE "Python - Install")] Installing $(_c LIGHT_YELLOW "$packages")"
  pip install "$@"
}
