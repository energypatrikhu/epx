#!/bin/bash

c.help() {
  __epx_echo "[$(_c LIGHT_BLUE "Common - Help")]"
  __epx_echo "  $(_c CYAN "Commands:")"
  __epx_echo "    $(_c LIGHT_CYAN "archive") - Archive files or directories"
  __epx_echo "    $(_c LIGHT_CYAN "unarchive") - Unarchive files or directories"
  __epx_echo "    $(_c LIGHT_CYAN "zst") - Zstandard compression commands"
  __epx_echo "    $(_c LIGHT_CYAN "unzst") - Zstandard decompression commands"
  __epx_echo "    $(_c LIGHT_CYAN "copy") - Copy files or directories"
  __epx_echo "    $(_c LIGHT_CYAN "move") - Move files or directories"
  __epx_echo "    $(_c LIGHT_CYAN "du-all") - Docker update all containers"
  __epx_echo "    $(_c LIGHT_CYAN "dcu") - Docker Compose up command"
}
