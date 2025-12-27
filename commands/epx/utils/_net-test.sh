#!/bin/bash

# Network connectivity tests

__epx_net_test() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  clear
  echo "╭────────────────────────────────────────────────────────────╮"
  echo "│ 🧪 NETWORK CONNECTIVITY TESTS                                │"
  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ Testing network connectivity...                             │"
  echo "│                                                             │"

  # Get network info
  local default_if=$(ip route | grep default | awk '{print $5}' | head -1)
  local gateway=$(ip route | grep default | awk '{print $3}' | head -1)
  local public_ip=$(curl -s -m 5 ifconfig.me 2>/dev/null || echo "Unknown")

  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ NETWORK CONFIGURATION                                       │"
  echo "│                                                             │"
  printf "│ Default Interface : %-40s │\n" "${default_if:-N/A}"
  printf "│ Default Gateway   : %-40s │\n" "${gateway:-N/A}"
  printf "│ Public IP         : %-40s │\n" "$public_ip"

  echo "│                                                             │"
  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ GATEWAY CONNECTIVITY                                        │"
  echo "│                                                             │"

  # Test gateway ping
  if [[ -n "$gateway" ]]; then
    local gw_result=$(ping -c 3 -W 2 "$gateway" 2>/dev/null)
    local gw_success=$(echo "$gw_result" | grep -c '3 received')

    if [[ $gw_success -eq 1 ]]; then
      local gw_ping=$(echo "$gw_result" | grep 'avg' | awk -F'/' '{print $5}')
      printf "│ Gateway ($gateway)                                    │\n"
      printf "│   Status    : ✅ REACHABLE                                │\n"
      printf "│   Latency   : %.1f ms (avg)                                │\n" "$gw_ping"

      local packet_loss=$(echo "$gw_result" | grep 'packet loss' | awk '{print $(NF-5)}')
      printf "│   Loss      : %s                                          │\n" "$packet_loss"
    else
      printf "│ Gateway ($gateway)                                    │\n"
      printf "│   Status    : ❌ UNREACHABLE                              │\n"
    fi
  else
    printf "│ No default gateway configured                           │\n"
  fi

  echo "│                                                             │"
  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ INTERNET CONNECTIVITY                                       │"
  echo "│                                                             │"

  # Test public DNS servers
  declare -A dns_servers=(
    ["Cloudflare"]="1.1.1.1"
    ["Google"]="8.8.8.8"
    ["Quad9"]="9.9.9.9"
  )

  for name in "${!dns_servers[@]}"; do
    local ip="${dns_servers[$name]}"
    local result=$(ping -c 3 -W 2 "$ip" 2>/dev/null)
    local success=$(echo "$result" | grep -c '3 received')

    if [[ $success -eq 1 ]]; then
      local avg_ping=$(echo "$result" | grep 'avg' | awk -F'/' '{print $5}')
      printf "│ %-15s ($ip)                                  │\n" "$name"
      printf "│   Status    : ✅ REACHABLE                                │\n"
      printf "│   Latency   : %.1f ms (avg)                                │\n" "$avg_ping"
    else
      printf "│ %-15s ($ip)                                  │\n" "$name"
      printf "│   Status    : ❌ UNREACHABLE                              │\n"
    fi
    echo "│                                                             │"
  done

  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ DNS RESOLUTION                                              │"
  echo "│                                                             │"

  # Test DNS resolution
  declare -a test_domains=(
    "google.com"
    "github.com"
    "cloudflare.com"
  )

  for domain in "${test_domains[@]}"; do
    local dns_result=$(nslookup "$domain" 2>/dev/null | grep -A1 'Name:' | tail -1 | awk '{print $2}')

    if [[ -n "$dns_result" ]]; then
      printf "│ %-20s → %-35s │\n" "$domain" "✅ $dns_result"
    else
      printf "│ %-20s → %-35s │\n" "$domain" "❌ FAILED"
    fi
  done

  echo "│                                                             │"
  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ HTTP/HTTPS CONNECTIVITY                                     │"
  echo "│                                                             │"

  # Test HTTP/HTTPS
  declare -A web_tests=(
    ["HTTP (Google)"]="http://www.google.com"
    ["HTTPS (Google)"]="https://www.google.com"
    ["HTTPS (GitHub)"]="https://api.github.com"
  )

  for name in "${!web_tests[@]}"; do
    local url="${web_tests[$name]}"
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "$url" 2>/dev/null)

    if [[ "$http_code" == "200" || "$http_code" == "301" || "$http_code" == "302" ]]; then
      printf "│ %-25s → ✅ OK (HTTP %s)                  │\n" "$name" "$http_code"
    else
      printf "│ %-25s → ❌ FAILED                        │\n" "$name"
    fi
  done

  echo "│                                                             │"
  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ LOCAL SERVICES                                              │"
  echo "│                                                             │"

  # Test common local services
  declare -A local_services=(
    ["SSH"]="22"
    ["HTTP"]="80"
    ["HTTPS"]="443"
    ["Home Assistant"]="8123"
    ["MQTT"]="1883"
  )

  for service in "${!local_services[@]}"; do
    local port="${local_services[$service]}"

    if ss -tln | grep -q ":$port "; then
      printf "│ %-25s (Port %-5s → ✅ LISTENING       │\n" "$service" "$port"
    else
      printf "│ %-25s (Port %-5s → ❌ NOT LISTENING   │\n" "$service" "$port"
    fi
  done

  echo "│                                                             │"
  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ TRACEROUTE TO 8.8.8.8                                       │"
  echo "│                                                             │"

  # Quick traceroute (first 5 hops)
  if command -v traceroute &>/dev/null; then
    traceroute -m 5 -w 1 8.8.8.8 2>/dev/null | tail -n +2 | head -5 | while read -r line; do
      printf "│ %s │\n" "$(printf '%-59s' "$line")"
    done
  else
    echo "│ traceroute command not available                            │"
  fi

  echo "│                                                             │"
  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ BANDWIDTH TEST                                              │"
  echo "│                                                             │"

  # Download speed test (using curl to download a small file)
  if command -v curl &>/dev/null; then
    echo "│ Testing download speed... (this may take a few seconds)    │"

    local test_url="http://speedtest.ftp.otenet.gr/files/test1Mb.db"
    local start_time=$(date +%s.%N)
    curl -s -o /dev/null "$test_url" 2>/dev/null
    local end_time=$(date +%s.%N)
    local duration=$(awk "BEGIN {print $end_time - $start_time}")
    local speed=$(awk "BEGIN {printf \"%.2f\", 8 / $duration}")

    printf "│ Download speed: ~%.2f Mbps                                  │\n" "$speed"
  else
    echo "│ curl not available for speed test                          │"
  fi

  echo "│                                                             │"
  echo "├────────────────────────────────────────────────────────────┤"
  printf "│ ⏱️  Last update: %-44s │\n" "$timestamp"
  echo "│ Tip: Run 'epx net:test' regularly to monitor connectivity   │"
  echo "╰────────────────────────────────────────────────────────────╯"
}
