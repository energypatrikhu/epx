#!/bin/bash

py.remove() {
  # check if Python is installed
  if ! command -v python3 &>/dev/null; then
    __epx_echo "[$(_c LIGHT_BLUE "Python - Remove")] $(_c LIGHT_RED "Python is not installed")"
    return 1
  fi

  # check if no arguments are provided
  if [ -z "$1" ]; then
    __epx_echo "[$(_c LIGHT_BLUE "Python - Remove")] $(_c LIGHT_YELLOW "Usage: py.remove <package>")"

    __epx_echo "[$(_c LIGHT_BLUE "Python - Remove")] $(_c LIGHT_YELLOW "Alias:")"
    __epx_echo "[$(_c LIGHT_BLUE "Python - Remove")] $(_c LIGHT_YELLOW "  py.rm <package>")"
    __epx_echo "[$(_c LIGHT_BLUE "Python - Remove")] $(_c LIGHT_YELLOW "  py.uninstall <package>")"
    return 1
  fi

  # remove package
  packages=$(printf "%s, " "$@" | sed 's/, $//')
  __epx_echo "[$(_c LIGHT_BLUE "Python - Remove")] Removing $(_c LIGHT_YELLOW "$packages")"
  pip uninstall "$@"

  # check if removal was successful, then remove from requirements.txt, line by line
  if [ $? -eq 0 ]; then
    for package in "$@"; do
      sed -i "/$package/d" requirements.txt
    done
  fi
}

py.rm() {
  py.remove "$@"
}

py.uninstall() {
  py.remove "$@"
}
