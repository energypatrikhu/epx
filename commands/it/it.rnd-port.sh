_help() {
  echo -e "[$(_c LIGHT_BLUE "IT - Random Port")] Usage: $(_c LIGHT_YELLOW "it.rnd-port")"
  echo -e "[$(_c LIGHT_BLUE "IT - Random Port")] Find an available random TCP port on the system"
  echo -e "[$(_c LIGHT_BLUE "IT - Random Port")]"
  echo -e "[$(_c LIGHT_BLUE "IT - Random Port")] Options:"
  echo -e "[$(_c LIGHT_BLUE "IT - Random Port")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "IT - Random Port")]"
  echo -e "[$(_c LIGHT_BLUE "IT - Random Port")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - Random Port")]   it.rnd-port"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "IT - Random Port")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg netstat:net-tools ss:iproute2

source "${EPX_HOME}/helpers/random-number.sh"

_is_port_in_use() {
  local port="${1-}"

  if netstat -tuln 2>/dev/null | grep -q ":$port "; then
    return 0
  fi

  if ss -tuln 2>/dev/null | grep -q ":$port "; then
    return 0
  fi

  return 1
}

_is_docker_port_used() {
  local port="${1-}"

  if ! command -v docker &>/dev/null; then
    return 1
  fi

  if docker ps --format "{{.Ports}}" 2>/dev/null | grep -q "$port"; then
    return 0
  fi

  return 1
}

_is_firewall_port_open() {
  local port="${1-}"

  if command -v ufw &>/dev/null && sudo ufw status 2>/dev/null | grep -q "Status: active"; then
    if sudo ufw status numbered 2>/dev/null | grep -q "$port"; then
      return 0
    fi
  fi

  return 1
}

_find_available_port() {
  local max_attempts=100
  local attempt=0
  local port_range=$((65535 - 1024 + 1))

  while [[ $attempt -lt $max_attempts ]]; do
    local rnd_val=$(_rnd_number)
    local port=$((rnd_val % port_range + 1024))

    if ! _is_port_in_use "$port" && ! _is_docker_port_used "$port" && ! _is_firewall_port_open "$port"; then
      echo "$port"
      return 0
    fi

    ((attempt++))
  done

  return 1
}

echo -e "[$(_c LIGHT_BLUE "IT - Random Port")] Searching for available port..."

available_port=$(_find_available_port)

if [[ -z "$available_port" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - Random Port")] $(_c LIGHT_RED "Error"): Could not find available port after 100 attempts"
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "IT - Random Port")] Checking port $(_c LIGHT_YELLOW "$available_port")..."
if _is_port_in_use "$available_port"; then
  echo -e "[$(_c LIGHT_BLUE "IT - Random Port")] $(_c LIGHT_YELLOW "Warning"): Port in use by system"
elif _is_docker_port_used "$available_port"; then
  echo -e "[$(_c LIGHT_BLUE "IT - Random Port")] $(_c LIGHT_YELLOW "Warning"): Port in use by Docker"
elif _is_firewall_port_open "$available_port"; then
  echo -e "[$(_c LIGHT_BLUE "IT - Random Port")] $(_c LIGHT_YELLOW "Warning"): Port open in firewall"
else
  echo -e "[$(_c LIGHT_BLUE "IT - Random Port")] $(_c LIGHT_GREEN "Port available")"
fi

echo "$available_port"
