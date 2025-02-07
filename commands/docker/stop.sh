d.stop() {
  if [[ -z $1 ]]; then
    printf "[$(_c LIGHT_BLUE "Docker - Stop")] $(_c LIGHT_YELLOW "Usage: d.stop <all / container>")\n"
    return
  fi

  if [[ $1 == "all" ]]; then
    docker container stop $(docker container ls -a -q) >/dev/null 2>&1

    printf "[$(_c LIGHT_BLUE "Docker - Stop")] $(_c LIGHT_RED "All containers stopped")\n"
  else
    docker container stop "$@" >/dev/null 2>&1

    if [ $# -eq 1 ]; then
      container_text="Container"
    else
      container_text="Containers"
    fi
    containers=$(printf "%s, " "$@" | sed 's/, $//')
    printf "[$(_c LIGHT_BLUE "Docker - Stop")] $(_c LIGHT_BLUE "$container_text $containers") $(_c LIGHT_RED "stopped")\n"
  fi
}

. $EPX_PATH/commands/docker/_autocomplete.sh
complete -F _d_autocomplete_all d.stop
