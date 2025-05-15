#!/bin/bash

zst() {
  [ "$#" -eq 0 ] && __epx_echo "No input files" && return

  fbasename=$(basename -- "$@")

  time tar -I "zstd -T0 --ultra -22 -v --auto-threads=logical --long -M8192" -cf "${fbasename}.tar.zst" "$@"
}

unzst() {
  [ "$#" -eq 0 ] && __epx_echo "No input files" && return

  fbasename=$(basename -- "$@")

  time tar --use-compress-program=unzstd -xvf "${fbasename}"
}
