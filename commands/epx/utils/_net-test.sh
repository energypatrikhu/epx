# Network connectivity tests

__epx_net_test() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  clear
  echo -e "$(_c LIGHT_CYAN "🧪 NETWORK CONNECTIVITY TESTS")"
  echo -e "$(_c LIGHT_CYAN "══════════════════════════════════════════════════════════════════════════════")"
  echo "Testing network connectivity..."

  # Get network info
  local default_if=$(ip route | grep default | awk '{print $5}' | head -1)
  local gateway=$(ip route | grep default | awk '{print $3}' | head -1)
  local public_ip=$(curl -s -m 5 ifconfig.me 2>/dev/null || echo "Unknown")

  _print_section "NETWORK CONFIGURATION"
  echo "  Default Interface : ${default_if:-N/A}"
  echo "  Default Gateway   : ${gateway:-N/A}"
  echo "  Public IP         : ${public_ip:0:40}"

  _print_section "GATEWAY CONNECTIVITY"

  # Test gateway ping
  if [[ -n "$gateway" ]]; then
    local gw_result=$(ping -c 3 -W 2 "$gateway" 2>/dev/null)
    local gw_success=$(echo "$gw_result" | grep -c '3 received')

    if [[ $gw_success -eq 1 ]]; then
      local gw_ping=$(echo "$gw_result" | grep 'avg' | awk -F'/' '{print $5}')
      echo "  Gateway ($gateway)"
      echo "    Status    : $(_c LIGHT_GREEN "✅ REACHABLE")"
      printf "    Latency   : %.1f ms (avg)\n" "$gw_ping"

      local packet_loss=$(echo "$gw_result" | grep 'packet loss' | awk '{print $(NF-6), $(NF-5), $(NF-4)}')
      echo "    Loss      : $packet_loss"
    else
      echo "  Gateway ($gateway)"
      echo "    Status    : $(_c LIGHT_RED "❌ UNREACHABLE")"
    fi
  else
    echo "  No default gateway configured"
  fi

  _print_section "INTERNET CONNECTIVITY"

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
      echo "  $name ($ip)"
      echo "    Status    : $(_c LIGHT_GREEN "✅ REACHABLE")"
      printf "    Latency   : %.1f ms (avg)\n" "$avg_ping"
    else
      echo "  $name ($ip)"
      echo "    Status    : $(_c LIGHT_RED "❌ UNREACHABLE")"
    fi
  done

  _print_section "DNS RESOLUTION"

  # Test DNS resolution
  declare -a test_domains=(
    "google.com"
    "github.com"
    "cloudflare.com"
  )

  for domain in "${test_domains[@]}"; do
    local dns_result=$(nslookup "$domain" 2>/dev/null | grep -A1 'Name:' | tail -1 | awk '{print $2}')

    if [[ -n "$dns_result" ]]; then
      echo "  $domain → ✅ $dns_result"
    else
      echo "  $domain → $(_c LIGHT_RED "❌ FAILED")"
    fi
  done

  _print_section "HTTP/HTTPS CONNECTIVITY"

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
      echo "  $name → $(_c LIGHT_GREEN "✅ OK") (HTTP $http_code)"
    else
      echo "  $name → $(_c LIGHT_RED "❌ FAILED")"
    fi
  done

  echo ""
  _print_section "LOCAL SERVICES"

  # Test common local services
  declare -A local_services=(
    ["SSH"]="22"
    ["HTTP"]="80"
    ["HTTPS"]="443"
  )

  for service in "${!local_services[@]}"; do
    local port="${local_services[$service]}"

    if ss -tln | grep -q ":$port "; then
      echo "  $service (Port $port) → $(_c LIGHT_GREEN "✅ LISTENING")"

    else
      echo "  $service (Port $port) → $(_c LIGHT_RED "❌ NOT LISTENING")"
    fi
  done

  _print_section "TRACEROUTE TO 8.8.8.8"

  # Quick traceroute (first 5 hops)
  if command -v traceroute &>/dev/null; then
    traceroute -m 5 -w 1 8.8.8.8 2>/dev/null | tail -n +2 | head -5 | while read -r line; do
      echo "  $line"
    done
  else
    echo "  traceroute command not available"
  fi

  _print_section "BANDWIDTH TEST"

  # Download speed test (using curl to download a small file)
  if command -v curl &>/dev/null; then
    echo "  Testing download speed... (this may take a few seconds)"

    local test_url="http://speedtest.ftp.otenet.gr/files/test1Mb.db"
    local start_time=$(date +%s.%N)
    curl -s -o /dev/null "$test_url" 2>/dev/null
    local end_time=$(date +%s.%N)
    local duration=$(awk "BEGIN {print $end_time - $start_time}")
    local speed=$(awk "BEGIN {printf \"%.2f\", 8 / $duration}")

    printf "  Download speed: ~%.2f Mbps\n" "$speed"
  else
    echo "  curl not available for speed test"
  fi

  echo ""
  echo "⏱️  Last update: $timestamp"
  echo "Tip: Run 'epx net-test' regularly to monitor connectivity"
}
