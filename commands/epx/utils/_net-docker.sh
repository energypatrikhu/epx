# Docker networking detailed view

__epx_net_docker() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  if ! command -v docker &>/dev/null; then
    echo -e "$(_c LIGHT_RED "Error: Docker is not installed")"
    return 1
  fi

  if ! docker ps &>/dev/null; then
    echo -e "$(_c LIGHT_RED "Error: Docker is not running or you don't have permission")"
    return 1
  fi

  clear
  echo -e "$(_c LIGHT_CYAN "🐳 DOCKER NETWORKING")"
  echo -e "$(_c LIGHT_CYAN "══════════════════════════════════════════════════════════════════════════════")"

  # Docker daemon info
  _print_section "DOCKER STATUS"

  local container_count=$(docker ps --format '{{.Names}}' | wc -l)
  local container_total=$(docker ps -a --format '{{.Names}}' | wc -l)
  local image_count=$(docker images -q | wc -l)
  local network_count=$(docker network ls -q | wc -l)

  echo "  Running containers  : $(_c LIGHT_GREEN "$container_count")"
  echo "  Total containers    : $(_c LIGHT_GREEN "$container_total")"
  echo "  Images              : $(_c LIGHT_GREEN "$image_count")"
  echo "  Networks            : $(_c LIGHT_GREEN "$network_count")"

  _print_section "DOCKER NETWORKS"

  # List all docker networks
  docker network ls --format '{{.Name}}\t{{.Driver}}\t{{.Scope}}' | while IFS=$'\t' read name driver scope; do
    printf "  %-20s  Driver: %-10s  Scope: %-8s\n" "$(_c LIGHT_CYAN "$name")" "$driver" "$scope"

    # Get network details
    local subnet=$(docker network inspect "$name" 2>/dev/null | grep -A1 '"Subnet"' | grep -o '[0-9.]*\/[0-9]*' | head -1)
    local gateway=$(docker network inspect "$name" 2>/dev/null | grep '"Gateway"' | head -1 | grep -o '[0-9.]*' | head -1)

    if [[ -n "$subnet" ]]; then
      printf "    Subnet: $(_c LIGHT_BLUE "%-50s")\n" "$subnet"
    fi
    if [[ -n "$gateway" ]]; then
      printf "    Gateway: $(_c LIGHT_BLUE "%-49s")\n" "$gateway"
    fi

    # Count containers on this network
    local container_count=$(docker network inspect "$name" 2>/dev/null | grep -c '"Name":' | tail -1)
    printf "    Containers: $(_c LIGHT_GREEN "%-46d")\n" "$((container_count - 1))"
    echo ""
  done

  _print_section "CONTAINER NETWORK DETAILS"

  # List containers with their network info
  docker ps --format '{{.Names}}' | while read container; do
    printf "  Container: %s\n" "$container"

    # Get IP addresses
    local ip_addr=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' "$container" 2>/dev/null | awk '{print $1}')
    local network=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}' "$container" 2>/dev/null | awk '{print $1}')
    local mac=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.MacAddress}} {{end}}' "$container" 2>/dev/null | awk '{print $1}')

    echo "    Network    : ${network:-N/A}"
    echo "    IP Address : $(_c LIGHT_BLUE "${ip_addr:-N/A}")"
    echo "    MAC Address: $(_c LIGHT_CYAN "${mac:-N/A}")"

    # Get port mappings
    local ports=$(docker port "$container" 2>/dev/null)
    if [[ -n "$ports" ]]; then
      echo "    Port Mappings:"
      echo "$ports" | while read port_map; do
      echo "      • $(_c LIGHT_GREEN "$port_map")"
      done
    else
      echo "    Port Mappings: $(_c LIGHT_YELLOW "None")"
    fi

    echo ""
  done

  # _print_section "PORT MAPPINGS SUMMARY"

  # # List all port mappings
  # docker ps --format '{{.Names}}\t{{.Ports}}' | while IFS=$'\t' read name ports; do
  #   if [[ -n "$ports" ]]; then
  #     # Extract host ports
  #     echo "$ports" | grep -o '[0-9]*->' | while read port_map; do
  #       # Remove '->' suffix using parameter expansion
  #       local host_port="${port_map%->}"
  #       printf "  Host:%-5s → %-47s\n" "$host_port" "$name"
  #     done
  #   fi
  # done

  # _print_section "CONTAINER CONNECTIVITY"

  # # Test connectivity between containers
  # local first_container=$(docker ps --format '{{.Names}}' | head -1)
  # if [[ -n "$first_container" ]]; then
  #   echo "  Testing from: $first_container"
  #   echo ""

  #   docker ps --format '{{.Names}}' | grep -v "^$first_container$" | head -5 | while read target; do
  #     local target_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$target" 2>/dev/null)

  #     if [[ -n "$target_ip" ]]; then
  #       local ping_result=$(docker exec "$first_container" ping -c 1 -W 1 "$target_ip" 2>/dev/null)
  #       if echo "$ping_result" | grep -q "1 received"; then
  #         printf "  ✅ %-20s → %-32s\n" "${target:0:20}" "$target_ip"
  #       else
  #         printf "  ❌ %-20s → %-32s\n" "${target:0:20}" "$target_ip"
  #       fi
  #     fi
  #   done
  # else
  #   echo "  No running containers to test"
  # fi

  _print_section "DOCKER IPTABLES RULES"

  # Check if docker has iptables rules
  local docker_chain_count=$(iptables -t nat -L -n 2>/dev/null | grep -c DOCKER || echo 0)
  echo "  Docker NAT rules    : $(_c LIGHT_GREEN "$docker_chain_count")"

  local forward_count=$(iptables -L DOCKER -n 2>/dev/null | grep -c ACCEPT || echo 0)
  echo "  Docker FORWARD rules: $(_c LIGHT_GREEN "$forward_count")"

  echo ""
  echo "⏱️  Last update: $timestamp"
  echo "Tip: Use 'docker network inspect <network>' for details"
}
