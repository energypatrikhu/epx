copy() {
  # Safety check
  [ "$#" -eq 0 ] && echo "No input files" && return

  time screen rsync -rxzvuahP --stats "$@"
}
