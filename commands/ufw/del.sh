#!/bin/bash

ufw.del() {
  if [ -z "$1" ]; then
    __epx_echo "[$(_c LIGHT_CYAN "UFW")] $(_c LIGHT_YELLOW "Usage: ufw.del <rule_number> / port <port>")"
    return 1
  fi

  if [[ "$1" =~ ^[0-9]+$ ]]; then
    ufw delete "$1"
    return
  fi

  # if $1 is 'port'
  if [ "$1" == "port" ]; then
    if [ -z "$2" ]; then
      __epx_echo "[$(_c LIGHT_CYAN "UFW")] $(_c LIGHT_YELLOW "Usage: ufw.del port <port>")"
      return 1
    fi

    ufw delete allow "$2"
    return
  fi
}
