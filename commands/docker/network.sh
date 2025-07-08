#!/bin/bash

d.net() {
  if [[ -z $1 ]]; then
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Network")] $(_c LIGHT_YELLOW "Usage: d.net <... options>")"
    return
  fi

  docker network "$@"
}

d.network() {
  d.net $@
}
