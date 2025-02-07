#!/bin/bash

_strip_text() {
  printf "%s" "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

_visible_length() {
  _strip_text "$1" | wc -m
}

d.stats() {
  container_name="$1"

  # If no container name is provided or if the container name is "all", list all containers
  if [ -z "$container_name" ] || [ "$container_name" = "all" ]; then
    containers=$(docker container ls -a --format "{{.Names}}")
    for container in $containers; do
      d.stats "$container"
    done

    return 1
  fi

  # Get container details using docker inspect
  container_info=$(docker inspect "$container_name" 2>/dev/null)

  if [ -z "$container_info" ]; then
    printf "Error: Container '%s' not found.\n" "$container_name"
    return 1
  fi

  # Extract relevant fields with null checks
  name=$(printf "%s" "$container_info" | jq -r '.[0].Name | sub("^/"; "")')
  image=$(printf "%s" "$container_info" | jq -r '.[0].Config.Image')

  start_date=$(printf "%s" "$container_info" | jq -r '.[0].State.StartedAt' | xargs -I {} date -d "{}" +"%Y-%m-%d %H:%M:%S")
  created_date=$(printf "%s" "$container_info" | jq -r '.[0].Created' | xargs -I {} date -d "{}" +"%Y-%m-%d %H:%M:%S")
  uptime=$(printf "%s" "$container_info" | jq -r '.[0].State.StartedAt' | xargs -I {} bash -c 'echo $((($(date +%s) - $(date -d "{}" +%s)) / 60))' | xargs -I {} bash -c 'echo $(({} / 60 / 24))d $(({} / 60 % 24))h $(({} % 60))m $(({} % 60))s')
  workdir=$(printf "%s" "$container_info" | jq -r '.[0].Config.WorkingDir // "n/a"')
  state=$(printf "%s" "$container_info" | jq -r '.[0].State.Status')
  network_mode=$(printf "%s" "$container_info" | jq -r '.[0].HostConfig.NetworkMode')

  # Extract volumes (handle null and empty arrays)
  volumes=$(printf "%s" "$container_info" | jq -r '
    if (.[0].Mounts | length) == 0 then "n/a"
    else .[0].Mounts[] | "\(.Source) -> \(.Destination)"
    end
  ')

  # Extract network details (handle null and empty objects)
  if [ "$network_mode" = "host" ]; then
    networks="Host network mode (no container-specific IPs)"
  else
    networks=$(printf "%s" "$container_info" | jq -r '
      .[0].NetworkSettings.Networks
      | if . == null or length == 0 then "n/a"
        else to_entries[] | "\(.key): \(
          .value.IPAddress // "n/a"
        ) (IPv4), \(
          .value.GlobalIPv6Address // "n/a"
        ) (IPv6)"
        end
    ')
  fi

  # Extract port mappings (handle null and empty objects)
  ports=$(printf "%s" "$container_info" | jq -r '
    .[0].NetworkSettings.Ports
    | if . == null or length == 0 then "n/a"
        else to_entries[] | "\(.key) -> \(.value[]?.HostPort // "n/a")"
      end
  ' | sort -u)

  # check if attr has value
  [ -z "$name" ] && name="-"
  [ -z "$image" ] && image="-"
  [ -z "$ports" ] && ports="-"
  [ -z "$start_date" ] || [ "$state" != "running" ] && start_date="-"
  [ -z "$created_date" ] && created_date="-"
  [ -z "$uptime" ] || [ "$state" != "running" ] && uptime="-"
  [ -z "$workdir" ] && workdir="-"
  [ -z "$state" ] && state="-"
  [ -z "$network_mode" ] && network_mode="-"
  [ -z "$volumes" ] && volumes="-"
  [ -z "$networks" ] || [ "$state" != "running" ] && networks="-"

  # Calculate dynamic column widths
  max_width() {
    max=0
    for str in "$@"; do
      len=${#str}
      ((len > max)) && max=$len
    done
    printf "%d" "$max"
  }

  # Colorize state
  if [ "$state" = "running" ]; then
    state="$(_c GREEN "$EPX_BULLET") $state"
  else
    state="$(_c RED "$EPX_BULLET") $state"
  fi

  attributes=("Name" "Image" "Start Date" "Created" "Up time" "WorkDir" "State" "Ports" "Volumes" "Networks")
  values=("$name" "$image" "$start_date" "$uptime" "$created_date" "$workdir" "$state")

  # Add volumes and networks to values for width calculation
  if [ -z "$volumes" ]; then
    values+=("No volumes mounted.")
  else
    while IFS= read -r volume; do
      values+=("$volume")
    done <<<"$volumes"
  fi

  if [ "$network_mode" = "host" ]; then
    values+=("$networks")
  else
    while IFS= read -r network; do
      values+=("$network")
    done <<<"$networks"
  fi

  if [ -z "$ports" ]; then
    values+=("No ports mapped.")
  else
    while IFS= read -r port; do
      values+=("$port")
    done <<<"$ports"
  fi

  # Calculate widths with padding, compensating for color codes
  attribute_width=$(max_width "${attributes[@]}")
  value_width=$(max_width "${values[@]}")

  # Print functions
  print_separator() {
    printf "+-%*s-+-%*s-+\n" "$attribute_width" "" "$value_width" "" | tr ' ' '-'
  }

  print_row() {
    attr="$1"
    val="$2"

    visible_len=$(_visible_length "$val")
    invisible_len=$((${#val} - visible_len))
    ((invisible_len > 1)) && invisible_len=$((invisible_len + 2))
    len=$((value_width + invisible_len))

    printf "| %-${attribute_width}s | %-${len}s |\n" "$attr" "$val"
  }

  # Start table
  print_separator

  # Main attributes
  print_row "Name" "$name"
  print_row "Image" "$image"
  print_row "Created" "$created_date"
  print_row "Started" "$start_date"
  print_row "Up time" "$uptime"
  print_row "WorkDir" "$workdir"
  print_row "State" "$state"
  print_separator

  # Ports
  if [ "$ports" = "n/a" ]; then
    print_row "Ports" "n/a"
  else
    first_port=true
    while IFS= read -r port; do
      if $first_port; then
        print_row "Ports" "$port"
        first_port=false
      else
        print_row "" "$port"
      fi
    done <<<"$ports"
  fi
  print_separator

  # Volumes
  if [ "$volumes" = "n/a" ]; then
    print_row "Volumes" "n/a"
  else
    first_volume=true
    while IFS= read -r volume; do
      if $first_volume; then
        print_row "Volumes" "$volume"
        first_volume=false
      else
        print_row "" "$volume"
      fi
    done <<<"$volumes"
  fi
  print_separator

  # Networks
  if [ "$network_mode" = "host" ]; then
    print_row "Networks" "$networks"
  else
    first_network=true
    while IFS= read -r network; do
      if $first_network; then
        print_row "Networks" "$network"
        first_network=false
      else
        print_row "" "$network"
      fi
    done <<<"$networks"
  fi
  print_separator
}

. $EPX_PATH/commands/docker/_autocomplete.sh
complete -F _d_autocomplete_all d.stats
