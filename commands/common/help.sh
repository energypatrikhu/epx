#!/bin/bash

c.help() {
  __epx_echo "[$(_c LIGHT_BLUE "Common - Help")]"
  __epx_echo "  $(_c LIGHT_BLUE "Commands:")"
  __epx_echo "    $(_c LIGHT_BLUE "archive") - Archive files or directories"
  __epx_echo "    $(_c LIGHT_BLUE "unarchive") - Unarchive files or directories"
  __epx_echo "    $(_c LIGHT_BLUE "zst") - Zstandard compression commands"
  __epx_echo "    $(_c LIGHT_BLUE "unzst") - Zstandard decompression commands"
  __epx_echo "    $(_c LIGHT_BLUE "copy") - Copy files or directories"
  __epx_echo "    $(_c LIGHT_BLUE "move") - Move files or directories"
  __epx_echo "    $(_c LIGHT_BLUE "du-all") - Docker update all containers"
  __epx_echo "    $(_c LIGHT_BLUE "dcu") - Docker Compose up command"
}
