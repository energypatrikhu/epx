#!/bin/bash

# Docker networking detailed view

__epx_net-docker() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  if ! command -v docker &>/dev/null; then
    echo "Error: Docker is not installed"
    return 1
  fi

  if ! docker ps &>/dev/null; then
    echo "Error: Docker is not running or you don't have permission"
    return 1
  fi

  clear
  echo "╭────────────────────────────────────────────────────────────╮"
  echo "│ 🐳 DOCKER NETWORKING                                         │"
  echo "├────────────────────────────────────────────────────────────┤"

  # Docker daemon info
  echo "│ DOCKER STATUS                                               │"
  echo "│                                                             │"

  local container_count=$(docker ps --format '{{.Names}}' | wc -l)
  local container_total=$(docker ps -a --format '{{.Names}}' | wc -l)
  local image_count=$(docker images -q | wc -l)
  local network_count=$(docker network ls -q | wc -l)

  printf "│ Running containers  : %-37d │\n" "$container_count"
  printf "│ Total containers    : %-37d │\n" "$container_total"
  printf "│ Images              : %-37d │\n" "$image_count"
  printf "│ Networks            : %-37d │\n" "$network_count"

  echo "│                                                             │"
  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ DOCKER NETWORKS                                             │"
  echo "│                                                             │"

  # List all docker networks
  docker network ls --format '{{.Name}}\t{{.Driver}}\t{{.Scope}}' | while IFS=$'\t' read name driver scope; do
    printf "│ %-20s  Driver: %-10s  Scope: %-8s │\n" "$name" "$driver" "$scope"

    # Get network details
    local subnet=$(docker network inspect "$name" 2>/dev/null | grep -A1 '"Subnet"' | grep -o '[0-9.]*\/[0-9]*' | head -1)
    local gateway=$(docker network inspect "$name" 2>/dev/null | grep '"Gateway"' | head -1 | grep -o '[0-9.]*' | head -1)

    if [[ -n "$subnet" ]]; then
      printf "│   Subnet: %-50s │\n" "$subnet"
    fi
    if [[ -n "$gateway" ]]; then
      printf "│   Gateway: %-49s │\n" "$gateway"
    fi

    # Count containers on this network
    local container_count=$(docker network inspect "$name" 2>/dev/null | grep -c '"Name":' | tail -1)
    printf "│   Containers: %-46d │\n" "$((container_count - 1))"
    echo "│                                                             │"
  done

  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ CONTAINER NETWORK DETAILS                                   │"
  echo "│                                                             │"

  # List containers with their network info
  docker ps --format '{{.Names}}' | while read container; do
    printf "│ ┌─ %-57s │\n" "$container"

    # Get IP addresses
    local ip_addr=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' "$container" 2>/dev/null | awk '{print $1}')
    local network=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}' "$container" 2>/dev/null | awk '{print $1}')
    local mac=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.MacAddress}} {{end}}' "$container" 2>/dev/null | awk '{print $1}')

    printf "│ │  Network    : %-46s │\n" "${network:-N/A}"
    printf "│ │  IP Address : %-46s │\n" "${ip_addr:-N/A}"
    printf "│ │  MAC Address: %-46s │\n" "${mac:-N/A}"

    # Get port mappings
    local ports=$(docker port "$container" 2>/dev/null)
    if [[ -n "$ports" ]]; then
      echo "│ │  Port Mappings:                                           │"
      echo "$ports" | while read port_map; do
        printf "│ │    %-54s │\n" "$port_map"
      done
    else
      echo "│ │  Port Mappings: None                                      │"
    fi

    echo "│ └─────────────────────────────────────────────────────────  │"
    echo "│                                                             │"
  done

  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ PORT MAPPINGS SUMMARY                                       │"
  echo "│                                                             │"

  # List all port mappings
  docker ps --format '{{.Names}}\t{{.Ports}}' | while IFS=$'\t' read name ports; do
    if [[ -n "$ports" ]]; then
      # Extract host ports
      echo "$ports" | grep -o '[0-9]*->' | while read port_map; do
        local host_port=$(echo "$port_map" | tr -d '->')
        printf "│ Host:%-5s → %-47s │\n" "$host_port" "$name"
      done
    fi
  done

  echo "│                                                             │"
  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ CONTAINER CONNECTIVITY                                      │"
  echo "│                                                             │"

  # Test connectivity between containers
  local first_container=$(docker ps --format '{{.Names}}' | head -1)
  if [[ -n "$first_container" ]]; then
    echo "│ Testing from: $first_container                              │"
    echo "│                                                             │"

    docker ps --format '{{.Names}}' | grep -v "^$first_container$" | head -5 | while read target; do
      local target_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$target" 2>/dev/null)

      if [[ -n "$target_ip" ]]; then
        local ping_result=$(docker exec "$first_container" ping -c 1 -W 1 "$target_ip" 2>/dev/null)
        if echo "$ping_result" | grep -q "1 received"; then
          printf "│ ✅ %-20s → %-33s │\n" "$target" "$target_ip"
        else
          printf "│ ❌ %-20s → %-33s │\n" "$target" "$target_ip"
        fi
      fi
    done
  else
    echo "│ No running containers to test                              │"
  fi

  echo "│                                                             │"
  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ DOCKER IPTABLES RULES                                       │"
  echo "│                                                             │"

  # Check if docker has iptables rules
  local docker_chain_count=$(iptables -t nat -L -n 2>/dev/null | grep -c DOCKER || echo 0)
  printf "│ Docker NAT rules    : %-37d │\n" "$docker_chain_count"

  local forward_count=$(iptables -L DOCKER -n 2>/dev/null | grep -c ACCEPT || echo 0)
  printf "│ Docker FORWARD rules: %-37d │\n" "$forward_count"

  echo "│                                                             │"
  echo "├────────────────────────────────────────────────────────────┤"
  printf "│ ⏱️  Last update: %-44s │\n" "$timestamp"
  echo "│ Tip: Use 'docker network inspect <network>' for details     │"
  echo "╰────────────────────────────────────────────────────────────╯"
}
