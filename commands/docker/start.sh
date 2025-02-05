d.up() {
  if [[ $1 == "all" ]]; then
    docker container start $(docker container ls -a -q)
  else
    docker container start $1
  fi
}

. $EPX_PATH/commands/docker/_autocomplete.sh
complete -F _d.autocomplete d.up
