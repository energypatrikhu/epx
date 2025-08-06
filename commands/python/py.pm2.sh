#!/bin/bash

source "${EPX_HOME}/helpers/check-command-installed.sh"
_cci python3 pm2

source "${EPX_HOME}/helpers/colorize.sh"
source "${EPX_HOME}/helpers/colors.sh"

# help message
if [ "${1}" = "-h" ] || [ "${1}" = "--help" ]; then
  echo -e "Usage: py.pm2 [script] [name]"
  return 0
fi

if [ -z "${1}" ]; then
  filename="main.py"
else
  filename="${1}"
fi

if [ -z "${2}" ]; then
  project_name=$(basename "${PWD}")
else
  project_name="${2}"
fi

# start Python script with PM2, for name use "${2}" if not available use ${PWD} last directory name
echo -e "[$(_c LIGHT_BLUE "Python - PM2")] Starting Python script with PM2"
pm2 start "${filename}" --interpreter="${PWD}/.venv/bin/python" --name="${project_name}" &>/dev/null

# save process list
echo -e "[$(_c LIGHT_BLUE "Python - PM2")] Saving process list"
pm2 save &>/dev/null
