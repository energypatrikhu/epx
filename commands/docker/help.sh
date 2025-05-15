#!/bin/bash

d.help() {
  __epx_echo "[$(_c LIGHT_BLUE "Docker - Help")] $(_c LIGHT_YELLOW "Usage: d.help <command>")"
  __epx_echo "  $(_c LIGHT_BLUE "Commands:")"
  __epx_echo "    $(_c LIGHT_BLUE "d.start") - Start a container"
  __epx_echo "    $(_c LIGHT_BLUE "d.restart") - Restart a container"
  __epx_echo "    $(_c LIGHT_BLUE "d.stop") - Stop a container"
  __epx_echo "    $(_c LIGHT_BLUE "d.shell") - Open a shell in a container"
  __epx_echo "    $(_c LIGHT_BLUE "d.logs") - View logs of a container"
  __epx_echo "    $(_c LIGHT_BLUE "d.list") - List all containers"
  __epx_echo "    $(_c LIGHT_BLUE "d.stats") - Display stats of a container"
  __epx_echo "    $(_c LIGHT_BLUE "d.help") - Display this help message"
  __epx_echo "  $(_c LIGHT_BLUE "Aliases:")"
  __epx_echo "    $(_c LIGHT_BLUE "d") - Docker"
  __epx_echo "    $(_c LIGHT_BLUE "dc") - Docker Compose"
}
