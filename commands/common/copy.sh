#!/bin/bash

copy() {
  [ "$#" -eq 0 ] && __epx_echo "No input files" && return

  time rsync -rxzvuahP --stats "$@"
}
