#!/bin/bash

py.pm2() {
  # help message
  if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    printf "%s\n" "Usage: py.pm2 [script] [name]"
    return 0
  fi

  # check if Python is installed
  if ! command -v python3 &>/dev/null; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Python - PM2")] $(_c LIGHT_RED "Python is not installed")"
    return 1
  fi

  # check if PM2 is installed
  if ! command -v pm2 &>/dev/null; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Python - PM2")] $(_c LIGHT_RED "PM2 is not installed")"
    return 1
  fi

  if [ -z "$1" ]; then
    filename="main.py"
  else
    filename=$1
  fi

  if [ -z "$2" ]; then
    project_name=$(basename "$PWD")
  else
    project_name=$2
  fi

  # start Python script with PM2, for name use "$2" if not available use $PWD last directory name
  printf "%s\n" "[$(_c LIGHT_BLUE "Python - PM2")] Starting Python script with PM2"
  pm2 start "$filename" --interpreter="$PWD/.venv/bin/python" --name="$project_name" &>/dev/null

  # save process list
  printf "%s\n" "[$(_c LIGHT_BLUE "Python - PM2")] Saving process list"
  pm2 save &>/dev/null
}
