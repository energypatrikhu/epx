_d_autocomplete_all() {
  local cur opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  # Get the list of all containers and the "all" keyword
  opts="all $(docker container ls -a --format '{{.Names}}')"

  # Generate autocomplete suggestions
  COMPREPLY=($(compgen -W "${opts}" -- "$cur"))
}

_d_autocomplete() {
  local cur opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  # Get the list of all containers and the "all" keyword
  opts="all $(docker container ls -a --format '{{.Names}}')"

  # Generate autocomplete suggestions
  COMPREPLY=($(compgen -W "${opts}" -- "$cur"))
}
