archive() {
  [ "$#" -eq 0 ] && printf "No input files\n" && return

  fbasename=$(basename -- "$@")

  time screen tar -cvf "${fbasename}.tar" "$@"
}

unarchive() {
  [ "$#" -eq 0 ] && printf "No input files\n" && return

  fbasename=$(basename -- "$@")

  time screen tar -xvf "${fbasename}"
}
