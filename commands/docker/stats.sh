_strip_text() {
  printf "%s" "$1" | sed 's/\x1b\[[0-9;]*m//g'
}

_visible_length() {
  _strip_text "$1" | wc -m
}

d.stats() {
  local container_name="$1"

  # If no container name is provided or if the container name is "all", list all containers
  if [ -z "$container_name" ] || [ "$container_name" = "all" ]; then
    local containers=$(docker container ls -a --format "{{.Names}}")
    for container in $containers; do
      d.stats "$container"
    done

    return 1
  fi

  # Get container details using docker inspect
  local container_info=$(docker inspect "$container_name" 2>/dev/null)

  if [ -z "$container_info" ]; then
    printf "Error: Container '%s' not found.\n" "$container_name"
    return 1
  fi

  # Extract relevant fields with null checks
  local name=$(printf "%s" "$container_info" | jq -r '.[0].Name | sub("^/"; "")')
  local image=$(printf "%s" "$container_info" | jq -r '.[0].Config.Image')

  local start_date=$(printf "%s" "$container_info" | jq -r '.[0].State.StartedAt')
  local workdir=$(printf "%s" "$container_info" | jq -r '.[0].Config.WorkingDir // "n/a"')
  local state=$(printf "%s" "$container_info" | jq -r '.[0].State.Status')
  local network_mode=$(printf "%s" "$container_info" | jq -r '.[0].HostConfig.NetworkMode')

  # Extract volumes (handle null and empty arrays)
  local volumes=$(printf "%s" "$container_info" | jq -r '
        if (.[0].Mounts | length) == 0 then "n/a"
        else .[0].Mounts[] | "\(.Source) -> \(.Destination)"
        end
    ')

  # Extract network details (handle null and empty objects)
  local networks
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
  local ports=$(printf "%s" "$container_info" | jq -r '
        .[0].NetworkSettings.Ports
        | if . == null or length == 0 then "n/a"
            else to_entries[] | "\(.key) -> \(.value[]?.HostPort // "n/a")"
          end
    ' | sort -u)

  # check if attr has value
  [ -z "$name" ] && name="-"
  [ -z "$image" ] && image="-"
  [ -z "$ports" ] && ports="-"
  [ -z "$start_date" ] && start_date="-"
  [ -z "$workdir" ] && workdir="-"
  [ -z "$state" ] && state="-"
  [ -z "$network_mode" ] && network_mode="-"
  [ -z "$volumes" ] && volumes="-"
  [ -z "$networks" ] && networks="-"

  # Calculate dynamic column widths
  max_width() {
    local max=0
    for str in "$@"; do
      local len=${#str}
      ((len > max)) && max=$len
    done
    printf "%d" "$max"
  }

  # Colorize state
  if [ "$state" = "running" ]; then
    state="$(_c GREEN $EPX_BULLET) $state"
  else
    state="$(_c RED $EPX_BULLET) $state"
  fi

  local attributes=("Name" "Image" "Start Date" "WorkDir" "State" "Ports" "Volumes" "Networks")
  local values=("$name" "$image" "$start_date" "$workdir" "$state")

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
  local attribute_width=$(max_width "${attributes[@]}")
  local value_width=$(max_width "${values[@]}")

  # Print functions
  print_separator() {
    printf "+-%*s-+-%*s-+\n" "$attribute_width" "" "$value_width" "" | tr ' ' '-'
  }

  print_row() {
    local attr="$1"
    local val="$2"

    local visible_len=$(_visible_length "$val")
    local invisible_len=$((${#val} - visible_len))
    ((invisible_len > 1)) && invisible_len=$(($invisible_len + 2))
    local len=$((value_width + invisible_len))

    printf "| %-${attribute_width}s | %-${len}s |\n" "$attr" "$val"
  }

  # Start table
  print_separator

  # Main attributes
  print_row "Name" "$name"
  print_row "Image" "$image"
  print_row "Start Date" "$start_date"
  print_row "WorkDir" "$workdir"
  print_row "State" "$state"
  print_separator

  # Ports
  print_row "Ports" ""
  if [ "$ports" = "n/a" ]; then
    print_row "" "n/a"
  else
    while IFS= read -r port; do
      print_row "" "$port"
    done <<<"$ports"
  fi
  print_separator

  # Volumes
  print_row "Volumes" ""
  if [ "$volumes" = "n/a" ]; then
    print_row "" "n/a"
  else
    while IFS= read -r volume; do
      print_row "" "$volume"
    done <<<"$volumes"
  fi
  print_separator

  # Networks
  print_row "Networks" ""
  if [ "$network_mode" = "host" ]; then
    print_row "" "$networks"
  else
    while IFS= read -r network; do
      print_row "" "$network"
    done <<<"$networks"
  fi
  print_separator
}

. $EPX_PATH/commands/docker/_autocomplete.sh
complete -F _d_autocomplete_all d.stats
