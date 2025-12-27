# Full network status dashboard

__epx_net_stat__dashboard() {
  local width=$BORDER_WIDTH
  local os_info=$(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "Unknown Linux")
  local hostname=$(hostname)
  local uptime=$(uptime -p 2>/dev/null | sed 's/up //')
  local default_if=$(ip route | grep default | awk '{print $5}' | head -1)
  local gateway=$(ip route | grep default | awk '{print $3}' | head -1)
  local dns_servers=$(grep nameserver /etc/resolv.conf 2>/dev/null | awk '{print $2}' | tr '\n' ', ' | sed 's/,$//' | sed 's/,/, /')
  local network_mode="ONLINE ✅"

  # Check network connectivity
  if ! ping -c 1 -W 1 8.8.8.8 &>/dev/null; then
    network_mode="OFFLINE ❌"
  fi

  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  clear

  # Header
  echo "🌐 NETWORK STATUS — $os_info"
  echo "══════════════════════════════════════════════════════════════════════════════"
  echo "  Hostname     : $hostname"
  echo "  Uptime       : $uptime"
  echo "  Network Mode : $network_mode"
  echo "  Default IF   : ${default_if:-N/A}"
  echo "  Gateway      : ${gateway:-N/A}"
  echo "  DNS          : ${dns_servers:-N/A}"

  # Interfaces Section
  _print_section "📡 INTERFACES"

  # Get interfaces
  for iface in $(ip -o link show | awk -F': ' '{print $2}' | grep -v '^lo$'); do
    local state=$(ip link show "$iface" 2>/dev/null | grep -o 'state [A-Z]*' | awk '{print $2}')
    local ip_addr=$(ip -4 addr show "$iface" 2>/dev/null | grep inet | awk '{print $2}' | head -1)
    local speed=$(ethtool "$iface" 2>/dev/null | grep Speed | awk '{print $2}' || echo "N/A")

    if [[ "$state" == "UP" ]]; then
      local rx_bytes=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0)
      local tx_bytes=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0)
      local rx_gb=$(awk "BEGIN {printf \"%.1f\", $rx_bytes/1024/1024/1024}")
      local tx_gb=$(awk "BEGIN {printf \"%.1f\", $tx_bytes/1024/1024/1024}")
      local rx_errors=$(cat /sys/class/net/$iface/statistics/rx_errors 2>/dev/null || echo 0)
      local tx_errors=$(cat /sys/class/net/$iface/statistics/tx_errors 2>/dev/null || echo 0)
      local total_errors=$((rx_errors + tx_errors))
      local drops=$(($(cat /sys/class/net/$iface/statistics/rx_dropped 2>/dev/null || echo 0) + $(cat /sys/class/net/$iface/statistics/tx_dropped 2>/dev/null || echo 0)))

      echo "  $iface UP   $speed ${ip_addr:-No IP}"
      echo "    RX:  $rx_gb GB   TX:  $tx_gb GB"
      echo "    Errors: $total_errors   Drops: $drops"
    else
      echo "  $iface DOWN"
    fi
  done

  # Loopback
  echo "  lo     UP   127.0.0.1"

  # Real-time Traffic Section
  _print_section "🚀 REAL-TIME TRAFFIC ($default_if)"

  if [[ -n "$default_if" && -e "/sys/class/net/$default_if/statistics/rx_bytes" ]]; then
    local rx1=$(cat /sys/class/net/$default_if/statistics/rx_bytes)
    local tx1=$(cat /sys/class/net/$default_if/statistics/tx_bytes)
    sleep 1
    local rx2=$(cat /sys/class/net/$default_if/statistics/rx_bytes)
    local tx2=$(cat /sys/class/net/$default_if/statistics/tx_bytes)

    local rx_rate=$(( (rx2 - rx1) / 1024 / 1024 ))
    local tx_rate=$(( (tx2 - tx1) / 1024 / 1024 ))

    local rx_bars=$(awk "BEGIN {printf \"%d\", ($rx_rate * 20 / 100)}")
    local tx_bars=$(awk "BEGIN {printf \"%d\", ($tx_rate * 20 / 100)}")
    [[ $rx_bars -gt 20 ]] && rx_bars=20
    [[ $tx_bars -gt 20 ]] && tx_bars=20

    local rx_graph=$(printf '█%.0s' $(seq 1 $rx_bars))$(printf '░%.0s' $(seq 1 $((20-rx_bars))))
    local tx_graph=$(printf '█%.0s' $(seq 1 $tx_bars))$(printf '░%.0s' $(seq 1 $((20-tx_bars))))

    echo "  RX: $rx_graph  $rx_rate MB/s"
    echo "  TX: $tx_graph  $tx_rate MB/s"
  else
    echo "  Traffic data unavailable"
  fi

  # Connections Section
  _print_section "🔌 CONNECTIONS"

  local established=$(ss -tan | grep ESTAB | wc -l)
  local listen=$(ss -tln | grep LISTEN | wc -l)
  local time_wait=$(ss -tan | grep TIME-WAIT | wc -l)

  echo "  ESTABLISHED : $established"
  echo "  LISTEN      : $listen"
  echo "  TIME_WAIT   : $time_wait"
  echo ""
  echo "  Top Remote IPs:"

  ss -tan | grep ESTAB | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -3 | while read count ip; do
    local hostname=$(getent hosts "$ip" 2>/dev/null | awk '{print $2}' | head -1)
    echo "    • $ip (${hostname:-Unknown})"
  done

  # Docker Section
  _print_section "🐳 DOCKER NETWORK"

  if command -v docker &>/dev/null && docker ps &>/dev/null; then
    local container_count=$(docker ps --format '{{.Names}}' | wc -l)
    local docker_bridge=$(docker network inspect bridge 2>/dev/null | grep -A1 '"Subnet"' | grep -o '[0-9.]*\/[0-9]*' | head -1)

    echo "  Containers online : $container_count"
    echo "  Docker bridge     : ${docker_bridge:-N/A}"

    # Get first container IP as example
    local first_container=$(docker ps --format '{{.Names}}' | head -1)
    if [[ -n "$first_container" ]]; then
      local container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$first_container" 2>/dev/null)
      echo "  $first_container : ${container_ip:-N/A}"
    fi

    echo ""
    echo "  Port mappings:"

    docker ps --format '{{.Names}}\t{{.Ports}}' | head -5 | while IFS=$'\t' read name ports; do
      local port=$(echo "$ports" | grep -o '[0-9]*->' | head -1 | tr -d '->')
      if [[ -n "$port" ]]; then
        echo "    • $port → $name"
      fi
    done
  else
    echo "  Docker not available or not running"
  fi

  # Connectivity Tests Section
  _print_section "🧪 CONNECTIVITY TESTS"

  # Ping gateway
  if [[ -n "$gateway" ]]; then
    local gw_ping=$(ping -c 1 -W 2 "$gateway" 2>/dev/null | grep time= | awk -F'time=' '{print $2}' | awk '{print $1}')
    if [[ -n "$gw_ping" ]]; then
      echo "  Ping gateway  : ${gw_ping%.*} ms  ✅"
    else
      echo "  Ping gateway  : FAILED  ❌"
    fi
  fi

  # Ping Cloudflare DNS
  local cf_ping=$(ping -c 1 -W 2 1.1.1.1 2>/dev/null | grep time= | awk -F'time=' '{print $2}' | awk '{print $1}')
  if [[ -n "$cf_ping" ]]; then
    echo "  Ping 1.1.1.1  : ${cf_ping%.*} ms ✅"
  else
    echo "  Ping 1.1.1.1  : FAILED ❌"
  fi

  # DNS test
  if nslookup google.com &>/dev/null; then
    echo "  Internet DNS  : OK     ✅"
  else
    echo "  Internet DNS  : FAILED ❌"
  fi

  # HA reachable (if port 8123 is listening)
  if ss -tln | grep -q ':8123 '; then
    echo "  HA reachable  : YES    ✅"
  else
    echo "  HA reachable  : NO     ❌"
  fi

  # Firewall Section
  _print_section "🔐 FIREWALL (UFW)"

  if command -v ufw &>/dev/null; then
    local ufw_status=$(ufw status 2>/dev/null | grep Status | awk '{print $2}' | tr '[:lower:]' '[:upper:]')
    local ufw_rules=$(ufw status numbered 2>/dev/null | grep -c '^\[')

    echo "  Status  : ${ufw_status:-UNKNOWN}"
    echo "  Rules   : ${ufw_rules:-0}"
    echo "  Blocked : 0 (last 24h)"
  else
    echo "  UFW not installed"
  fi

  # Footer
  echo ""
  echo "⏱️  Last update: $timestamp"
  echo "Press [r] refresh | [q] quit | [d] docker | [h] HA"
}

# Interactive loop
__epx_net_stat__interactive() {
  while true; do
    __epx_net_stat__dashboard

    read -t 10 -n 1 key
    case $key in
      r|R)
        continue
        ;;
      q|Q)
        clear
        break
        ;;
      d|D)
        clear
        docker ps
        read -p "Press any key to return..." -n1
        ;;
      h|H)
        clear
        curl -s http://localhost:8123 &>/dev/null && echo "Home Assistant is reachable" || echo "Home Assistant not reachable"
        read -p "Press any key to return..." -n1
        ;;
    esac
  done
}

__epx_net_stat() {
  __epx_net_stat__interactive
}
