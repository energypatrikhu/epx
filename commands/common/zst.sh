zst() {
  [ "$#" -eq 0 ] && echo "No input files" && return

  fbasename=$(basename -- "$@")

  time screen tar -I "zstd -T0 --ultra -22 -v --auto-threads=logical --long -M8192" -cf "${fbasename}.tar.zst" "$@"
}

unzst() {
  [ "$#" -eq 0 ] && echo "No input files" && return

  fbasename=$(basename -- "$@")

  time screen tar --use-compress-program=unzstd -xvf "${fbasename}"
}
