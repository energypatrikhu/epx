#!/bin/bash

c.help() {
  __epx_echo "[$(_c LIGHT_BLUE "Common - Help")] $(_c LIGHT_YELLOW "Usage: c.help <command >")"
  __epx_echo "  $(_c LIGHT_BLUE "Commands:")"
  __epx_echo "    $(_c LIGHT_BLUE "c.archive") - Archive files or directories"
  __epx_echo "    $(_c LIGHT_BLUE "c.copy") - Copy files or directories"
  __epx_echo "    $(_c LIGHT_BLUE "c.docker") - Docker utility commands"
  __epx_echo "    $(_c LIGHT_BLUE "c.move") - Move files or directories"
  __epx_echo "    $(_c LIGHT_BLUE "c.zst") - Zstandard compression commands"
  __epx_echo "    $(_c LIGHT_BLUE "c.help") - Display this help message"
}
