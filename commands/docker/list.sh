d.list() {
  state_filter=$1

  if [ -z "$state_filter" ]; then
    data=$(docker container ls -a --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}")
  else
    data=$(docker container ls -a --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" --filter "status=$state_filter")
  fi

  if [ -z "$data" ]; then
    printf "[${EPX_COLORS["LIGHT_BLUE"]}Docker${EPX_COLORS["NC"]}] ${EPX_COLORS["LIGHT_YELLOW"]}No containers found${EPX_COLORS["NC"]}\n"
    return
  fi

  id_width=12
  names_width=5
  image_width=5
  status_width=7

  while IFS=$'\t' read -r id names image status; do
    id_width=$((${#id} > id_width ? ${#id} : id_width))
    names_width=$((${#names} > names_width ? ${#names} : names_width))
    image_width=$((${#image} > image_width ? ${#image} : image_width))
    status_width=$((${#status} > status_width ? ${#status} : status_width))
  done <<EOF
$data
EOF

  names_width=$((names_width + 2))
  separator=$(printf "+%-${id_width}s--+%-${names_width}s--+%-${image_width}s--+%-${status_width}s--+\n" | tr ' ' '-')

  echo "$separator"
  printf "| %-${id_width}s | %-${names_width}s | %-${image_width}s | %-${status_width}s |\n" "CONTAINER ID" "NAMES" "IMAGE" "STATUS"
  echo "$separator"

  while IFS=$'\t' read -r id names image status; do

    if echo "$status" | grep -q "Exited" || echo "$status" | grep -q "Dead"; then
      bullet="$(printf '\033[31m●\033[0m')"
    else
      bullet="$(printf '\033[32m●\033[0m')"
    fi

    names="$bullet $names"
    visible_names_length=$(printf "%s" "$names" | sed 's/\x1b\[[0-9;]*m//g' | wc -m)
    padding=$((names_width - visible_names_length))

    printf "| %-${id_width}s | %s%-${padding}s | %-${image_width}s | %-${status_width}s |\n" "$id" "$names" "" "$image" "$status"
  done <<EOF
$data
EOF

  echo "$separator"
}

. $EPX_PATH/commands/docker/_autocomplete.sh
complete -F _d_autocomplete_list d.list
