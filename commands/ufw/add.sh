#!/bin/bash

ufw.del() {
  if [ -z "$1" ]; then
    printf "%s\n" "[$(_c LIGHT_CYAN "UFW")] $(_c LIGHT_YELLOW "Usage: ufw.add <port>")"
    return 1
  fi

  if [[ "$1" =~ ^[0-9]+$ ]]; then
    ufw allow "$1"
    return
  fi

  printf "%s\n" "[$(_c LIGHT_CYAN "UFW")] $(_c LIGHT_RED "Error:") $(_c LIGHT_YELLOW "Invalid argument: $1")"
}
