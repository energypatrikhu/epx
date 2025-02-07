d.start() {
  if [[ -z $1 ]]; then
    printf "[$(_c LIGHT_BLUE "Docker - Start")] $(_c LIGHT_YELLOW "Usage: d.start <all / container>")\n"
    return
  fi

  if [[ $1 == "all" ]]; then
    docker container start $(docker container ls -a -q) >/dev/null 2>&1

    printf "[$(_c LIGHT_BLUE "Docker - Start")] $(_c LIGHT_GREEN "All containers started")\n"
  else
    docker container start "$@" >/dev/null 2>&1

    if [ $# -eq 1 ]; then
      container_text="Container"
    else
      container_text="Containers"
    fi
    containers=$(printf "$(_c LIGHT_BLUE "%s"), " "$@" | sed 's/, $//')
    printf "[$(_c LIGHT_BLUE "Docker - Start")] $container_text $containers $(_c LIGHT_GREEN "started")\n"
  fi
}

. $EPX_PATH/commands/docker/_autocomplete.sh
complete -F _d_autocomplete_all d.start
