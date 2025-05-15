#!/bin/bash

py.create() {
  # check if Python is installed
  if ! command -v python3 &>/dev/null; then
    __epx_echo "[$(_c LIGHT_BLUE "Python - Create")] $(_c LIGHT_RED "Python is not installed")"
    return 1
  fi

  # check if directory is provided
  if [ -z "$1" ]; then
    __epx_echo "[$(_c LIGHT_BLUE "Python - Create")] $(_c LIGHT_YELLOW "Usage: py.create <directory>")"
    return 1
  fi

  # check if directory already exists
  if [ -d "$1" ]; then
    __epx_echo "[$(_c LIGHT_BLUE "Python - Create")] $(_c LIGHT_RED "Directory") $1 $(_c LIGHT_RED "already exists")"
    return 1
  fi

  # create directory
  __epx_echo "[$(_c LIGHT_BLUE "Python - Create")] Creating directory $(_c LIGHT_YELLOW "$1")"
  mkdir -p "$1"

  # change directory
  __epx_echo "[$(_c LIGHT_BLUE "Python - Create")] Changing directory to $(_c LIGHT_YELLOW "$1")"
  cd "$1" || return 1

  # create requirements.txt and main.py
  __epx_echo "[$(_c LIGHT_BLUE "Python - Create")] Creating $(_c LIGHT_YELLOW "requirements.txt") and $(_c LIGHT_YELLOW "main.py")"
  touch requirements.txt
  touch main.py

  # create virtual environment
  __epx_echo "[$(_c LIGHT_BLUE "Python - Create")] Creating virtual environment"
  python3 -m venv .venv

  # check if virtual environment is created
  if [ ! -d .venv ]; then
    __epx_echo "[$(_c LIGHT_BLUE "Python - Create")] $(_c LIGHT_RED "Failed to create virtual environment")"
    return 1
  fi

  # activate virtual environment
  __epx_echo "[$(_c LIGHT_BLUE "Python - Create")] Activating virtual environment"
  source .venv/bin/activate

  # inform user how to deactivate virtual environment
  __epx_echo "[$(_c LIGHT_BLUE "Python - Create")] To deactivate virtual environment, run $(_c LIGHT_YELLOW "deactivate") or $(_c LIGHT_YELLOW "py.venv")"
}
