#!/bin/bash

archive() {
  [ "$#" -eq 0 ] && __epx_echo "No input files" && return

  fbasename=$(basename -- "$@")

  time tar -cvf "${fbasename}.tar" "$@"
}

unarchive() {
  [ "$#" -eq 0 ] && __epx_echo "No input files" && return

  fbasename=$(basename -- "$@")

  time tar -xvf "${fbasename}"
}
