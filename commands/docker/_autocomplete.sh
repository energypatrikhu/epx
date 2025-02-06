_d_autocomplete() {
  _autocomplete "$(docker container ls --format '{{.Names}}')"
}

_d_autocomplete_all() {
  _autocomplete "all $(docker container ls -a --format '{{.Names}}')"
}

_d_autocomplete_list() {
  _autocomplete "created restarting running removing paused exited dead"
}
