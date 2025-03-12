#!/bin/bash

archive() {
  [ "$#" -eq 0 ] && printf "No input files\n" && return

  fbasename=$(basename -- "$@")

  time tar -cvf "${fbasename}.tar" "$@"
}

unarchive() {
  [ "$#" -eq 0 ] && printf "No input files\n" && return

  fbasename=$(basename -- "$@")

  time tar -xvf "${fbasename}"
}
