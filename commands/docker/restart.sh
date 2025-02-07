d.restart() {
  if [[ -z $1 ]]; then
    printf "[$(_c LIGHT_BLUE "Docker - Restart")] $(_c LIGHT_YELLOW "Usage: d.restart <all / container>")\n"
    return
  fi

  if [[ $1 == "all" ]]; then
    docker container restart $(docker container ls -a -q) >/dev/null 2>&1
    printf "[$(_c LIGHT_BLUE "Docker - Restart")] $(_c LIGHT_CYAN "All containers restarted")\n"
  else
    docker container restart "$@" >/dev/null 2>&1

    if [ $# -eq 1 ]; then
      container_text="Container"
    else
      container_text="Containers"
    fi
    containers=$(printf "$(_c LIGHT_BLUE "%s"), " "$@" | sed 's/, $//')
    printf "[$(_c LIGHT_BLUE "Docker - Restart")] $container_text $containers $(_c LIGHT_CYAN "restarted")\n"
  fi
}

. $EPX_PATH/commands/docker/_autocomplete.sh
complete -F _d_autocomplete_all d.restart
