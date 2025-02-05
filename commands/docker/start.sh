d.up() {
  if [[ $1 == "all" ]]; then
    docker container start $(docker container ls -a -q)
  else
    docker container start $1
  fi
}

# . $EPX_PATH/commands/docker/_autocomplete.sh

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
complete -F _d.autocomplete d.up
