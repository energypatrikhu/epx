move() {
  # Safety check
  [ "$#" -eq 0 ] && echo "No input files" && return

  time screen rsync -rxzvuahP --remove-source-files --stats "$@" && find "$1" -type d -empty -delete
}
