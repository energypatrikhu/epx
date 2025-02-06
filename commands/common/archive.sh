archive() {
  [ "$#" -eq 0 ] && echo "No input files" && return

  fbasename=$(basename -- "$@")

  time screen tar -cvf "${fbasename}.tar" "$@"
}

unarchive() {
  [ "$#" -eq 0 ] && echo "No input files" && return

  fbasename=$(basename -- "$@")

  time screen tar -xvf "${fbasename}"
}
