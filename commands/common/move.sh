#!/bin/bash

move() {
  [ "$#" -eq 0 ] && __epx_echo "No input files" && return

  time rsync -rxzvuahP --remove-source-files --stats "$@" && find "$1" -type d -empty -delete
}
