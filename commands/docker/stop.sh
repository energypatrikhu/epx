d.stop() {
  if [[ -z $1 ]]; then
    printf "[${EPX_COLORS["LIGHT_BLUE"]}Docker${EPX_COLORS["NC"]}] ${EPX_COLORS["LIGHT_YELLOW"]}Usage: d.stop <all / container>${EPX_COLORS["NC"]}\n"
    return
  fi

  if [[ $1 == "all" ]]; then
    docker container stop $(docker container ls -a -q) >/dev/null 2>&1

    printf "[${EPX_COLORS["LIGHT_BLUE"]}Docker${EPX_COLORS["NC"]}] All containers ${EPX_COLORS["LIGHT_RED"]}stopped${EPX_COLORS["NC"]}\n"
  else
    docker container stop "$@" >/dev/null 2>&1

    if [ $# -eq 1 ]; then
      container_text="Container"
    else
      container_text="Containers"
    fi
    containers=$(printf "${EPX_COLORS["LIGHT_BLUE"]}%s${EPX_COLORS["NC"]}, " "$@" | sed 's/, $//')
    printf "[${EPX_COLORS["LIGHT_BLUE"]}Docker${EPX_COLORS["NC"]}] ${container_text} %s ${EPX_COLORS["LIGHT_RED"]}stopped${EPX_COLORS["NC"]}\n" "$containers"
  fi
}

. $EPX_PATH/commands/docker/_autocomplete.sh
complete -F _d_autocomplete_all d.stop
