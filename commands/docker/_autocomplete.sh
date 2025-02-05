_d.autocomplete() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"
  opts="all $(docker container ls -a --format '{{.Names}}')"

  if [[ ${cur} == -* ]]; then
    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    return 0
  fi
}
