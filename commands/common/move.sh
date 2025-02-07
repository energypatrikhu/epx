#!/bin/bash

move() {
  [ "$#" -eq 0 ] && printf "No input files\n" && return

  time screen rsync -rxzvuahP --remove-source-files --stats "$@" && find "$1" -type d -empty -delete
}
