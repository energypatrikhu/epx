_help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - Stats")] Usage: $(_c LIGHT_YELLOW "d.stats <container / all>")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Stats")] Display detailed statistics for a specific Docker container or all containers"
  echo -e "[$(_c LIGHT_BLUE "Docker - Stats")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Stats")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Stats")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "Docker - Stats")]   -a, --all         Display stats for all containers"
  echo -e "[$(_c LIGHT_BLUE "Docker - Stats")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Stats")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Stats")]   d.stats my_container"
}

opt_help=false
opt_all=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    elif [[ "${arg}" =~ ^-*a(ll)?$ ]]; then
      opt_all=true
    else
      echo -e "[$(_c LIGHT_BLUE "Docker - Stats")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg docker:docker-ce-cli

_strip_text() {
  printf "%s" "${1-}" | sed 's/\x1b\[[0-9;]*m//g'
}

_visible_length() {
  _strip_text "${1-}" | wc -m
}

container_name="${1-}"

# If no container name is provided or opt_all is true, list all containers
if [[ -z "${container_name}" || "${opt_all}" == "true" ]]; then
  containers=$(docker ps -a --format "{{.Names}}")
  for container in ${containers}; do
    d.stats "${container}"
  done

  exit 0
fi

# Get container details using docker inspect
container_info=$(docker inspect "${container_name}" 2>/dev/null)

if [[ -z "${container_info}" ]]; then
  echo -e "Error: Container '${container_name}' not found."
  exit 1
fi

# Extract relevant fields with null checks
name=$(printf "%s" "${container_info}" | jq -r '.[0].Name | sub("^/"; "")')
image=$(printf "%s" "${container_info}" | jq -r '.[0].Config.Image')

start_date=$(printf "%s" "${container_info}" | jq -r '.[0].State.StartedAt' | xargs -I {} date -d "{}" +"%Y-%m-%d %H:%M:%S")
created_date=$(printf "%s" "${container_info}" | jq -r '.[0].Created' | xargs -I {} date -d "{}" +"%Y-%m-%d %H:%M:%S")
uptime=$(printf "%s" "${container_info}" | jq -r '.[0].State.StartedAt' | xargs -I {} bash -c 'echo $((($(date +%s) - $(date -d "{}" +%s)) / 60))' | xargs -I {} bash -c 'echo $(({} / 60 / 24))d $(({} / 60 % 24))h $(({} % 60))m $(({} % 60))s')
workdir=$(printf "%s" "${container_info}" | jq -r '.[0].Config.WorkingDir // "n/a"')
state=$(printf "%s" "${container_info}" | jq -r '.[0].State.Status')
network_mode=$(printf "%s" "${container_info}" | jq -r '.[0].HostConfig.NetworkMode')

# Extract environment variables, truncating values to fit console width
console_width=$(tput cols)
truncated_length=$((console_width - 19)) # Reserve space for padding and labels
environments=$(printf "%s" "${container_info}" | jq -r --argjson maxlen "${truncated_length}" '
  .[0].Config.Env
  | if . == null or length == 0 then "n/a"
    else map(
      capture("^(?<key>[^=]+)=(?<value>.*)")
      | .key as $k
      | .value as $v
      | ($k + ": ") as $prefix
      | ($maxlen - ($prefix | length)) as $val_max
      | "\($k): \($v | if (length > $val_max) then .[:($val_max-3)] + "..." else . end)"
    ) | .[]
    end
')

# Extract volumes (handle null and empty arrays)
volumes=$(printf "%s" "${container_info}" | jq -r '
  if (.[0].Mounts | length) == 0 then "n/a"
  else .[0].Mounts[] | "\(.Source) -> \(.Destination) (\(.RW | if . then "rw" else "ro" end))"
  end
')

# Extract network details (handle null and empty objects)
networks=""
if [[ "${network_mode}" = "host" ]]; then
  networks="Host network mode (no container-specific IPs)"
else
  networks=$(printf "%s" "${container_info}" | jq -r '
    .[0].NetworkSettings.Networks
    | if . == null or length == 0 then "n/a"
      else to_entries[] |
        .key,
        (if .value.IPAddress != null and .value.IPAddress != "" then "  IPv4: " + .value.IPAddress else empty end),
        (if .value.GlobalIPv6Address != null and .value.GlobalIPv6Address != "" then "  IPv6: " + .value.GlobalIPv6Address else empty end)
      end
  ')
fi

# Extract port mappings (handle null and empty objects)
ports=$(printf "%s" "${container_info}" | jq -r '
  .[0].NetworkSettings.Ports
  | if . == null or length == 0 then "n/a"
      else to_entries[] | "\(.key) -> \(.value[]?.HostPort // "n/a")"
    end
' | sort -u)

# check if attr has value
[[ -z "${name}" ]] && name="-"
[[ -z "${image}" ]] && image="-"
[[ -z "${ports}" ]] && ports="-"
[[ -z "${start_date}" || "${state}" != "running" ]] && start_date="-"
[[ -z "${created_date}" ]] && created_date="-"
[[ -z "${uptime}" || "${state}" != "running" ]] && uptime="-"
[[ -z "${workdir}" ]] && workdir="-"
[[ -z "${state}" ]] && state="-"
[[ -z "${network_mode}" ]] && network_mode="-"
[[ -z "${environments}" ]] && environments="-"
[[ -z "${volumes}" ]] && volumes="-"
[[ -z "${networks}" || "${state}" != "running" ]] && networks="-"

# Calculate dynamic column widths
max_width() {
  max=0
  for str in "${@}"; do
    len=${#str}
    ((len > max)) && max=${len}
  done
  printf "%d" "${max}"
}

# Colorize state
if [[ "${state}" = "running" ]]; then
  state="$(_c GREEN "${EPX_BULLET}") ${state}"
else
  state="$(_c RED "${EPX_BULLET}") ${state}"
fi

attributes=("Name" "Image" "Start Date" "Created" "Up time" "WorkDir" "State" "Environments" "Ports" "Volumes" "Networks")
values=("${name}" "${image}" "${start_date}" "${created_date}" "${uptime}" "${workdir}" "${state}")

# Add environments, volumes and networks to values for width calculation
if [[ -z "${environments}" ]]; then
  values+=("No environment variables set.")
else
  while IFS= read -r env; do
    values+=("${env}")
  done <<<"${environments}"
fi

if [[ -z "${ports}" ]]; then
  values+=("No ports mapped.")
else
  while IFS= read -r port; do
    values+=("${port}")
  done <<<"${ports}"
fi

if [[ -z "${volumes}" ]]; then
  values+=("No volumes mounted.")
else
  while IFS= read -r volume; do
    values+=("${volume}")
  done <<<"${volumes}"
fi

if [[ "${network_mode}" = "host" ]]; then
  values+=("${networks}")
else
  while IFS= read -r network; do
    values+=("${network}")
  done <<<"${networks}"
fi

# Calculate widths with padding, compensating for color codes
attribute_width=$(max_width "${attributes[@]}")
value_width=$(max_width "${values[@]}")

# Print functions
print_separator() {
  printf "+-%*s-+-%*s-+\n" "${attribute_width}" "" "${value_width}" "" | tr ' ' '-'
}

print_row() {
  attr="${1-}"
  val="${2-}"

  visible_len=$(_visible_length "${val}")
  invisible_len=$((${#val} - visible_len))
  ((invisible_len > 1)) && invisible_len=$((invisible_len + 2))
  len=$((value_width + invisible_len))

  printf "| %-${attribute_width}s | %-${len}s |\n" "${attr}" "${val}"
}

# Start table
print_separator

# Main attributes
print_row "Name" "${name}"
print_row "Image" "${image}"
print_row "Created" "${created_date}"
print_row "Started" "${start_date}"
print_row "Up time" "${uptime}"
print_row "WorkDir" "${workdir}"
print_row "State" "${state}"
print_separator

# Environments
if [[ "${environments}" = "n/a" ]]; then
  print_row "Environments" "n/a"
else
  first_env=true
  envs_sorted=()
  unset sorted_envs # Ensure no leftover values from previous runs
  while IFS= read -r env; do
    envs_sorted+=("${env}")
  done <<<"${environments}"
  IFS=$'\n' read -rd '' -a sorted_envs < <(printf "%s\n" "${envs_sorted[@]}" | sort && printf '\0')
  for env in "${sorted_envs[@]}"; do
    if "${first_env}"; then
      print_row "Environments" "${env}"
      first_env=false
    else
      print_row "" "${env}"
    fi
  done
  unset envs_sorted sorted_envs # Clean up for next container
fi
print_separator

# Ports
if [[ "${ports}" = "n/a" ]]; then
  print_row "Ports" "n/a"
else
  first_port=true
  ports_sorted=()
  unset sorted_ports # Ensure no leftover values from previous runs
  while IFS= read -r port; do
    ports_sorted+=("${port}")
  done <<<"${ports}"
  IFS=$'\n' read -rd '' -a sorted_ports < <(printf "%s\n" "${ports_sorted[@]}" | sort && printf '\0')
  for port in "${sorted_ports[@]}"; do
    if "${first_port}"; then
      print_row "Ports" "${port}"
      first_port=false
    else
      print_row "" "${port}"
    fi
  done
  unset ports_sorted sorted_ports # Clean up for next container
fi
print_separator

# Volumes
if [[ "${volumes}" = "n/a" ]]; then
  print_row "Volumes" "n/a"
else
  first_volume=true
  volumes_sorted=()
  unset sorted_volumes # Ensure no leftover values from previous runs
  while IFS= read -r volume; do
    volumes_sorted+=("${volume}")
  done <<<"${volumes}"
  IFS=$'\n' read -rd '' -a sorted_volumes < <(printf "%s\n" "${volumes_sorted[@]}" | sort && printf '\0')
  for volume in "${sorted_volumes[@]}"; do
    if "${first_volume}"; then
      print_row "Volumes" "${volume}"
      first_volume=false
    else
      print_row "" "${volume}"
    fi
  done
  unset volumes_sorted sorted_volumes # Clean up for next container
fi
print_separator

# Networks
if [[ "${network_mode}" = "host" ]]; then
  print_row "Networks" "${networks}"
else
  first_network=true
  while IFS= read -r network; do
    if "${first_network}"; then
      print_row "Networks" "${network}"
      first_network=false
    else
      print_row "" "${network}"
    fi
  done <<<"${networks}"
fi
print_separator
