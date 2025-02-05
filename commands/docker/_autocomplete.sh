_d_autocomplete_all() {
  local cur opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  opts="all $(docker container ls -a --format '{{.Names}}')"

  COMPREPLY=($(compgen -W "${opts}" -- "$cur"))
}

_d_autocomplete() {
  local cur opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  opts="$(docker container ls -a --format '{{.Names}}')"

  COMPREPLY=($(compgen -W "${opts}" -- "$cur"))
}

_d_autocomplete_list() {
  local cur opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  opts="created restarting running removing paused exited dead"

  COMPREPLY=($(compgen -W "${opts}" -- "$cur"))
}
