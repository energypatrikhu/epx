_d_autocomplete_base() {
  local cur opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  opts=$@

  COMPREPLY=($(compgen -W "${opts}" -- "$cur"))
}

_d_autocomplete() {
  _d_autocomplete_base "$(docker container ls --format '{{.Names}}')"
}

_d_autocomplete_all() {
  _d_autocomplete_base "all $(docker container ls -a --format '{{.Names}}')"
}

_d_autocomplete_list() {
  _d_autocomplete_base "created restarting running removing paused exited dead"
}
