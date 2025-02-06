ufw.del() {
  if [ -z "$1" ]; then
    printf "[${EPX_COLORS["LIGHT_CYAN"]}UFW${EPX_COLORS["NC"]}] ${EPX_COLORS["LIGHT_YELLOW"]}Usage: ufw.del <rule_number> / port <port>${EPX_COLORS["NC"]}\n"
    return 1
  fi

  if [[ "$1" =~ ^[0-9]+$ ]]; then
    ufw delete $1
    return
  fi

  # if $1 is 'port'
  if [ "$1" == "port" ]; then
    if [ -z "$2" ]; then
      printf "[${EPX_COLORS["LIGHT_CYAN"]}UFW${EPX_COLORS["NC"]}] ${EPX_COLORS["LIGHT_YELLOW"]}Usage: ufw.del port <port>${EPX_COLORS["NC"]}\n"
      return 1
    fi

    ufw delete allow $2
    return
  fi
}
