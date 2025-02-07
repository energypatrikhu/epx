#!/bin/bash

d.help() {
  printf "%s\n" "[$(_c LIGHT_BLUE "Docker - Help")] $(_c LIGHT_YELLOW "Usage: d.help <command>")"
  printf "  %s\n" "$(_c LIGHT_BLUE "Commands:")"
  printf "    %s\n" "$(_c LIGHT_BLUE "d.start") - Start a container"
  printf "    %s\n" "$(_c LIGHT_BLUE "d.restart") - Restart a container"
  printf "    %s\n" "$(_c LIGHT_BLUE "d.stop") - Stop a container"
  printf "    %s\n" "$(_c LIGHT_BLUE "d.shell") - Open a shell in a container"
  printf "    %s\n" "$(_c LIGHT_BLUE "d.logs") - View logs of a container"
  printf "    %s\n" "$(_c LIGHT_BLUE "d.list") - List all containers"
  printf "    %s\n" "$(_c LIGHT_BLUE "d.stats") - Display stats of a container"
  printf "    %s\n" "$(_c LIGHT_BLUE "d.help") - Display this help message"
  printf "  %s\n" "$(_c LIGHT_BLUE "Aliases:")"
  printf "    %s\n" "$(_c LIGHT_BLUE "d") - Docker"
  printf "    %s\n" "$(_c LIGHT_BLUE "dc") - Docker Compose"
}
