#!/bin/bash

py.help() {
  __epx_echo "[$(_c LIGHT_BLUE "Python - Help")]"
  __epx_echo "  $(_c CYAN "Commands:")"
  __epx_echo "    $(_c LIGHT_CYAN "py.create") - Create a new Python project or environment"
  __epx_echo "    $(_c LIGHT_CYAN "py.install") - Install Python packages"
  __epx_echo "    $(_c LIGHT_CYAN "py.pm2") - Manage Python processes with PM2"
  __epx_echo "    $(_c LIGHT_CYAN "py.remove") - Remove Python packages or environments"
  __epx_echo "    $(_c LIGHT_CYAN "py.venv") - Manage Python virtual environments"
  __epx_echo "    $(_c LIGHT_CYAN "py.help") - Display this help message"
}
