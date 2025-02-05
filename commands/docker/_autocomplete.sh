_d_autocomplete() {
  local cur opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  # Get the list of all stopped containers and "all" option
  opts="all $(docker container ls -a --format '{{.Names}}')"

  # Generate autocomplete suggestions
  COMPREPLY=($(compgen -W "${opts}" -- "$cur"))
}
