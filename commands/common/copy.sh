#!/bin/bash

copy() {
  [ "$#" -eq 0 ] && printf "No input files\n" && return

  time rsync -rxzvuahP --stats "$@"
}
