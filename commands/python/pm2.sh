#!/bin/bash

py.pm2() {
  # help message
  if [ -z "$1" ]; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Python - PM2")] $(_c LIGHT_YELLOW "Usage: py.pm2 <script> [name]")"
    printf "%s\n" "[$(_c LIGHT_BLUE "Python - PM2")] $(_c LIGHT_YELLOW "Description: Start Python script with PM2")"
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

  # start Python script with PM2, for name use "$2" if not available use "$1"
  printf "%s\n" "[$(_c LIGHT_BLUE "Python - PM2")] Starting Python script with PM2"
  if [ -z "$2" ]; then
    pm2 start "$1" --interpreter="$PWD/.venv/bin/python" &>/dev/null
  else
    pm2 start "$1" --interpreter="$PWD/.venv/bin/python" --name="$2" &>/dev/null
  fi

  # save process list
  printf "%s\n" "[$(_c LIGHT_BLUE "Python - PM2")] Saving process list"
  pm2 save &>/dev/null
}
