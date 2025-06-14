#!/bin/bash

py.help() {
  __epx_echo "[$(_c LIGHT_BLUE "Python - Help")]"
  __epx_echo "  $(_c LIGHT_BLUE "Commands:")"
  __epx_echo "    $(_c LIGHT_BLUE "py.create") - Create a new Python project or environment"
  __epx_echo "    $(_c LIGHT_BLUE "py.install") - Install Python packages"
  __epx_echo "    $(_c LIGHT_BLUE "py.pm2") - Manage Python processes with PM2"
  __epx_echo "    $(_c LIGHT_BLUE "py.remove") - Remove Python packages or environments"
  __epx_echo "    $(_c LIGHT_BLUE "py.venv") - Manage Python virtual environments"
  __epx_echo "    $(_c LIGHT_BLUE "py.help") - Display this help message"
}
