#!/bin/bash

p.help() {
  __epx_echo "[$(_c LIGHT_BLUE \"Python - Help\")] $(_c LIGHT_YELLOW \"Usage: p.help <command >\")"
  __epx_echo "  $(_c LIGHT_BLUE \"Commands:\")"
  __epx_echo "    $(_c LIGHT_BLUE \"p.create\") - Create a new Python project or environment"
  __epx_echo "    $(_c LIGHT_BLUE \"p.install\") - Install Python packages"
  __epx_echo "    $(_c LIGHT_BLUE \"p.pm2\") - Manage Python processes with PM2"
  __epx_echo "    $(_c LIGHT_BLUE \"p.remove\") - Remove Python packages or environments"
  __epx_echo "    $(_c LIGHT_BLUE \"p.venv\") - Manage Python virtual environments"
  __epx_echo "    $(_c LIGHT_BLUE \"p.help\") - Display this help message"
}
