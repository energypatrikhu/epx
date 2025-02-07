#!/bin/bash

py.remove() {
  # check if Python is installed
  if ! command -v python3 &>/dev/null; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Python - Remove")] $(_c LIGHT_RED "Python is not installed")"
    return 1
  fi

  # check if no arguments are provided
  if [ -z "$1" ]; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Python - Remove")] $(_c LIGHT_YELLOW "Usage: py.<uninstall, remove, rm> <package>")"
    return 1
  fi

  # remove package
  packages=$(printf "%s, " "$@" | sed 's/, $//')
  printf "%s\n" "[$(_c LIGHT_BLUE "Python - Remove")] Removing $(_c LIGHT_YELLOW "$packages")"
  pip uninstall "$@"
}

py.rm() {
  py.remove "$@"
}

py.uninstall() {
  py.remove "$@"
}
