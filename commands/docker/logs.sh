d.logs() {
  if [[ -z $1 ]]; then
    printf "[$(_c LIGHT_BLUE "Docker - Logs")] $(_c LIGHT_YELLOW "Usage: d.logs <container>")\n"
    return
  fi

  docker container logs -f "$@"
}

. $EPX_PATH/commands/docker/_autocomplete.sh
complete -F _d_autocomplete d.logs
