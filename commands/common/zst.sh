#!/bin/bash

zst() {
  [ "$#" -eq 0 ] && printf "No input files\n" && return

  fbasename=$(basename -- "$@")

  time tar -I "zstd -T0 --ultra -22 -v --auto-threads=logical --long -M8192" -cf "${fbasename}.tar.zst" "$@"
}

unzst() {
  [ "$#" -eq 0 ] && printf "No input files\n" && return

  fbasename=$(basename -- "$@")

  time tar --use-compress-program=unzstd -xvf "${fbasename}"
}
