copy() {
  [ "$#" -eq 0 ] && printf "No input files\n" && return

  time screen rsync -rxzvuahP --stats "$@"
}
