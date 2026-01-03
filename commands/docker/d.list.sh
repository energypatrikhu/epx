_help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - List")] Usage: $(_c LIGHT_YELLOW "d.list [status]")"
  echo -e "[$(_c LIGHT_BLUE "Docker - List")] List Docker containers with optional status filtering"
  echo -e "[$(_c LIGHT_BLUE "Docker - List")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - List")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Docker - List")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "Docker - List")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - List")] Status Filters:"
  echo -e "[$(_c LIGHT_BLUE "Docker - List")]   created"
  echo -e "[$(_c LIGHT_BLUE "Docker - List")]   restarting"
  echo -e "[$(_c LIGHT_BLUE "Docker - List")]   running"
  echo -e "[$(_c LIGHT_BLUE "Docker - List")]   removing"
  echo -e "[$(_c LIGHT_BLUE "Docker - List")]   paused"
  echo -e "[$(_c LIGHT_BLUE "Docker - List")]   exited"
  echo -e "[$(_c LIGHT_BLUE "Docker - List")]   dead"
  echo -e "[$(_c LIGHT_BLUE "Docker - List")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - List")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Docker - List")]   d.list"
  echo -e "[$(_c LIGHT_BLUE "Docker - List")]   d.list running"
  echo -e "[$(_c LIGHT_BLUE "Docker - List")]   d.list exited paused"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "Docker - List")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci docker

if [[ -z $* ]]; then
  data=$(docker ps -a --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}")
else
  filters=""
  for filter in ${@}; do
    filters="${filters} --filter status=${filter}"
  done
  data=$(docker ps -a --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" "${filters}")
fi

if [[ -z "${data}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - List")] $(_c LIGHT_YELLOW "No containers found")"
  exit
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
${data}
EOF

names_width=$((names_width + 2))
separator=$(printf "+%-${id_width}s--+%-${names_width}s--+%-${image_width}s--+%-${status_width}s--+\n" | tr ' ' '-')

echo -e "${separator}"
printf "| %-${id_width}s | %-${names_width}s | %-${image_width}s | %-${status_width}s |\n" "CONTAINER ID" "NAME" "IMAGE" "STATUS"
echo -e "${separator}"

# Sort data by the second column (names)
sorted_data=$(printf "%s\n" "${data}" | sort -k2,2)

while IFS=$'\t' read -r id names image status; do

  if printf "%s" "${status}" | grep -q "Up"; then
    bullet=$(_c GREEN "${EPX_BULLET}")
  else
    bullet=$(_c RED "${EPX_BULLET}")
  fi

  names="${bullet} ${names}"
  visible_names_length=$(printf "%s" "${names}" | sed 's/\x1b\[[0-9;]*m//g' | wc -m)
  padding=$((names_width - visible_names_length))

  printf "| %-${id_width}s | %s%-${padding}s | %-${image_width}s | %-${status_width}s |\n" "${id}" "${names}" "" "${image}" "${status}"
done <<EOF
${sorted_data}
EOF

echo -e "${separator}"
