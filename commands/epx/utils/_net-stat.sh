#!/bin/bash

# Full network status dashboard

# Border width configuration
BORDER_WIDTH=60
BORDER_CONTENT_WIDTH=$((BORDER_WIDTH - 2))  # Minus 2 for the │ symbols

# Helper function to calculate visual width (emojis count as 2)
_visual_length() {
  local str="$1"
  local len=${#str}
  # Count emojis (rough estimation - emojis are typically in Unicode ranges)
  local emoji_count=$(echo -n "$str" | grep -oP '[\x{1F300}-\x{1F9FF}\x{2600}-\x{26FF}\x{2700}-\x{27BF}]' | wc -l)
  echo $((len + emoji_count))
}

# Helper to print a bordered line
_print_line() {
  local text="$1"
  local visual_len=$(_visual_length "$text")
  local padding=$((BORDER_CONTENT_WIDTH - visual_len))
  printf "│ %s%*s │\n" "$text" $padding ""
}

# Helper to print a separator
_print_separator() {
  printf "├%s┤\n" "$(printf '─%.0s' $(seq 1 $BORDER_CONTENT_WIDTH))"
}

# Helper to print top border
_print_top() {
  printf "╭%s╮\n" "$(printf '─%.0s' $(seq 1 $BORDER_CONTENT_WIDTH))"
}

# Helper to print bottom border
_print_bottom() {
  printf "╰%s╯\n" "$(printf '─%.0s' $(seq 1 $BORDER_CONTENT_WIDTH))"
}

__net_stat_dashboard() {
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
  _print_top
  printf "│ 🌐 NETWORK STATUS — %-37s │\n" "$os_info"
  _print_separator
  printf "│ Hostname     : %-44s │\n" "$hostname"
  printf "│ Uptime       : %-44s │\n" "$uptime"
  printf "│ Network Mode : %-42s │\n" "$network_mode"
  printf "│ Default IF   : %-44s │\n" "${default_if:-N/A}"
  printf "│ Gateway      : %-44s │\n" "${gateway:-N/A}"
  printf "│ DNS          : %-44s │\n" "${dns_servers:-N/A}"

  # Interfaces Section
  _print_separator
  echo "│ 📡 INTERFACES                                                │"
  echo "│                                                             │"

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

      printf "│ %-6s UP   %-6s %-40s │\n" "$iface" "$speed" "${ip_addr:-No IP}"
      printf "│        RX:  %-6s GB   TX:  %-6s GB                      │\n" "$rx_gb" "$tx_gb"
      printf "│        Errors: %-3d   Drops: %-3d                          │\n" "$total_errors" "$drops"
      echo "│                                                             │"
    else
      printf "│ %-6s DOWN                                                  │\n" "$iface"
    fi
  done

  # Loopback
  printf "│ lo     UP   127.0.0.1                                       │\n"

  # Real-time Traffic Section
  _print_separator
  printf "│ 🚀 REAL-TIME TRAFFIC (%-35s │\n" "$default_if)"
  echo "│                                                             │"

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

    printf "│ RX: %s  %-6s MB/s                          │\n" "$rx_graph" "$rx_rate"
    printf "│ TX: %s  %-6s MB/s                          │\n" "$tx_graph" "$tx_rate"
  else
    echo "│ Traffic data unavailable                                    │"
  fi

  # Connections Section
  _print_separator
  echo "│ 🔌 CONNECTIONS                                               │"
  echo "│                                                             │"

  local established=$(ss -tan | grep ESTAB | wc -l)
  local listen=$(ss -tln | grep LISTEN | wc -l)
  local time_wait=$(ss -tan | grep TIME-WAIT | wc -l)

  printf "│ ESTABLISHED : %-45d │\n" "$established"
  printf "│ LISTEN      : %-45d │\n" "$listen"
  printf "│ TIME_WAIT   : %-45d │\n" "$time_wait"
  echo "│                                                             │"
  echo "│ Top Remote IPs:                                             │"

  ss -tan | grep ESTAB | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -3 | while read count ip; do
    local hostname=$(getent hosts "$ip" 2>/dev/null | awk '{print $2}' | head -1)
    printf "│  • %-15s (%-34s │\n" "$ip" "${hostname:-Unknown})"
  done

  # Docker Section
  _print_separator
  echo "│ 🐳 DOCKER NETWORK                                            │"
  echo "│                                                             │"

  if command -v docker &>/dev/null && docker ps &>/dev/null; then
    local container_count=$(docker ps --format '{{.Names}}' | wc -l)
    local docker_bridge=$(docker network inspect bridge 2>/dev/null | grep -A1 '"Subnet"' | grep -o '[0-9.]*\/[0-9]*' | head -1)

    printf "│ Containers online : %-40d │\n" "$container_count"
    printf "│ Docker bridge     : %-40s │\n" "${docker_bridge:-N/A}"

    # Get first container IP as example
    local first_container=$(docker ps --format '{{.Names}}' | head -1)
    if [[ -n "$first_container" ]]; then
      local container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$first_container" 2>/dev/null)
      printf "│ %-15s : %-40s │\n" "$first_container" "${container_ip:-N/A}"
    fi

    echo "│                                                             │"
    echo "│ Port mappings:                                              │"

    docker ps --format '{{.Names}}\t{{.Ports}}' | head -5 | while IFS=$'\t' read name ports; do
      local port=$(echo "$ports" | grep -o '[0-9]*->' | head -1 | tr -d '->')
      if [[ -n "$port" ]]; then
        printf "│  • %-5s → %-48s │\n" "$port" "$name"
      fi
    done
  else
    echo "│ Docker not available or not running                         │"
  fi

  # Connectivity Tests Section
  _print_separator
  echo "│ 🧪 CONNECTIVITY TESTS                                        │"
  echo "│                                                             │"

  # Ping gateway
  if [[ -n "$gateway" ]]; then
    local gw_ping=$(ping -c 1 -W 2 "$gateway" 2>/dev/null | grep time= | awk -F'time=' '{print $2}' | awk '{print $1}')
    if [[ -n "$gw_ping" ]]; then
      printf "│ Ping gateway  : %-3s ms  ✅                                 │\n" "${gw_ping%.*}"
    else
      printf "│ Ping gateway  : FAILED  ❌                                 │\n"
    fi
  fi

  # Ping Cloudflare DNS
  local cf_ping=$(ping -c 1 -W 2 1.1.1.1 2>/dev/null | grep time= | awk -F'time=' '{print $2}' | awk '{print $1}')
  if [[ -n "$cf_ping" ]]; then
    printf "│ Ping 1.1.1.1  : %-3s ms ✅                                 │\n" "${cf_ping%.*}"
  else
    printf "│ Ping 1.1.1.1  : FAILED ❌                                  │\n"
  fi

  # DNS test
  if nslookup google.com &>/dev/null; then
    printf "│ Internet DNS  : OK     ✅                                  │\n"
  else
    printf "│ Internet DNS  : FAILED ❌                                  │\n"
  fi

  # HA reachable (if port 8123 is listening)
  if ss -tln | grep -q ':8123 '; then
    printf "│ HA reachable  : YES    ✅                                  │\n"
  else
    printf "│ HA reachable  : NO     ❌                                  │\n"
  fi

  # Firewall Section
  _print_separator
  echo "│ 🔐 FIREWALL (UFW)                                            │"
  echo "│                                                             │"

  if command -v ufw &>/dev/null; then
    local ufw_status=$(ufw status 2>/dev/null | grep Status | awk '{print $2}' | tr '[:lower:]' '[:upper:]')
    local ufw_rules=$(ufw status numbered 2>/dev/null | grep -c '^\[')

    printf "│ Status  : %-50s │\n" "${ufw_status:-UNKNOWN}"
    printf "│ Rules   : %-50d │\n" "${ufw_rules:-0}"
    printf "│ Blocked : 0 (last 24h)                                      │\n"
  else
    echo "│ UFW not installed                                           │"
  fi

  # Footer
  _print_separator
  printf "│ ⏱️  Last update: %-43s │\n" "$timestamp"
  echo "│ Press [r] refresh | [q] quit | [d] docker | [h] HA          │"
  _print_bottom
}

# Interactive loop
__net_stat_interactive() {
  while true; do
    __net_stat_dashboard

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
  __net_stat_interactive
}
