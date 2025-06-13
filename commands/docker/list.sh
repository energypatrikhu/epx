#!/bin/bash

d.list() {
  state_filter="$*"

  if [ -z "$state_filter" ]; then
    data=$(docker ps -a --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}")
  else
    filters=""
    for filter in $state_filter; do
      filters="$filters --filter status=$filter"
    done
    data=$(docker ps -a --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" "$filters")
  fi

  if [ -z "$data" ]; then
    __epx_echo "[$(_c LIGHT_BLUE "Docker - List")] $(_c LIGHT_YELLOW "No containers found")"
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

  __epx_echo "$separator"
  printf "| %-${id_width}s | %-${names_width}s | %-${image_width}s | %-${status_width}s |\n" "CONTAINER ID" "NAME" "IMAGE" "STATUS"
  __epx_echo "$separator"

  # Sort data by the second column (names)
  sorted_data=$(printf "%s\n" "$data" | sort -k2,2)

  while IFS=$'\t' read -r id names image status; do

    if printf "%s" "$status" | grep -q "Up"; then
      bullet=$(_c GREEN "$EPX_BULLET")
    else
      bullet=$(_c RED "$EPX_BULLET")
    fi

    names="$bullet $names"
    visible_names_length=$(printf "%s" "$names" | sed 's/\x1b\[[0-9;]*m//g' | wc -m)
    padding=$((names_width - visible_names_length))

    printf "| %-${id_width}s | %s%-${padding}s | %-${image_width}s | %-${status_width}s |\n" "$id" "$names" "" "$image" "$status"
  done <<EOF
$sorted_data
EOF

  __epx_echo "$separator"
}
d.ls() {
  d.list $@
}

. "$EPX_PATH/commands/docker/_autocomplete.sh"
complete -F _d_autocomplete_list d.list
complete -F _d_autocomplete_list d.ls
