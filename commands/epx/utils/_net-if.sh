# Network interfaces detailed view

__epx_net_if() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  clear
  echo -e "$(_c LIGHT_CYAN "📡 NETWORK INTERFACES")"
  echo -e "$(_c LIGHT_CYAN "══════════════════════════════════════════════════════════════════════════════")"

  # Iterate through all network interfaces
  for iface in $(ip -o link show | awk -F': ' '{print $2}'); do
    local state=$(ip link show "$iface" 2>/dev/null | grep -o 'state [A-Z]*' | awk '{print $2}')
    local mtu=$(ip link show "$iface" 2>/dev/null | grep -o 'mtu [0-9]*' | awk '{print $2}')
    local mac=$(ip link show "$iface" 2>/dev/null | grep -o 'link/ether [^ ]*' | awk '{print $2}')

    # Get IPv4 addresses
    local ipv4_addrs=$(ip -4 addr show "$iface" 2>/dev/null | grep inet | awk '{print $2}')

    # Get IPv6 addresses
    local ipv6_addrs=$(ip -6 addr show "$iface" 2>/dev/null | grep inet6 | grep -v 'scope link' | awk '{print $2}')

    echo ""
    echo -e "  $(_c LIGHT_GREEN "$iface")"
    echo -e "  $(_c LIGHT_CYAN "────────────────────────────────────────────────────────────────────────────")"
    echo "    State      : $(_c LIGHT_YELLOW "$state")"
    echo "    MTU        : $(_c LIGHT_GREEN "${mtu:-N/A}")"

    if [[ -n "$mac" ]]; then
      echo "    MAC        : $(_c LIGHT_BLUE "$mac")"
    fi

    # Speed and duplex (only for physical interfaces)
    if [[ "$iface" != "lo" ]] && command -v ethtool &>/dev/null; then
      local speed=$(ethtool "$iface" 2>/dev/null | grep Speed | awk '{print $2}')
      local duplex=$(ethtool "$iface" 2>/dev/null | grep Duplex | awk '{print $2}')

      if [[ -n "$speed" ]]; then
        echo "    Speed      : $(_c LIGHT_CYAN "$speed")"
      fi

      if [[ -n "$duplex" ]]; then
        echo "    Duplex     : $(_c LIGHT_CYAN "$duplex")"
      fi
    fi

    # IPv4 addresses
    if [[ -n "$ipv4_addrs" ]]; then
      echo ""
      echo "    IPv4 Addresses:"
      while IFS= read -r addr; do
        echo "      • $(_c LIGHT_BLUE "$addr")"
      done <<< "$ipv4_addrs"
    fi

    # IPv6 addresses
    if [[ -n "$ipv6_addrs" ]]; then
      echo ""
      echo "    IPv6 Addresses:"
      while IFS= read -r addr; do
        echo "      • $(_c LIGHT_BLUE "$addr")"
      done <<< "$ipv6_addrs"
    fi

    # Statistics
    if [[ -e "/sys/class/net/$iface/statistics/rx_bytes" ]]; then
      local rx_bytes=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0)
      local tx_bytes=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0)
      local rx_packets=$(cat /sys/class/net/$iface/statistics/rx_packets 2>/dev/null || echo 0)
      local tx_packets=$(cat /sys/class/net/$iface/statistics/tx_packets 2>/dev/null || echo 0)
      local rx_errors=$(cat /sys/class/net/$iface/statistics/rx_errors 2>/dev/null || echo 0)
      local tx_errors=$(cat /sys/class/net/$iface/statistics/tx_errors 2>/dev/null || echo 0)
      local rx_dropped=$(cat /sys/class/net/$iface/statistics/rx_dropped 2>/dev/null || echo 0)
      local tx_dropped=$(cat /sys/class/net/$iface/statistics/tx_dropped 2>/dev/null || echo 0)

      local rx_gb=$(awk "BEGIN {printf \"%.2f\", $rx_bytes/1024/1024/1024}")
      local tx_gb=$(awk "BEGIN {printf \"%.2f\", $tx_bytes/1024/1024/1024}")

      echo ""
      echo "    Statistics:"
      echo "      RX: $(_c LIGHT_GREEN "$rx_gb GB") ($(_c LIGHT_YELLOW "$rx_packets") packets)"
      echo "      TX: $(_c LIGHT_GREEN "$tx_gb GB") ($(_c LIGHT_YELLOW "$tx_packets") packets)"
      echo "      Errors: RX=$(_c LIGHT_RED "$rx_errors") TX=$(_c LIGHT_RED "$tx_errors")"
      echo "      Dropped: RX=$(_c LIGHT_YELLOW "$rx_dropped") TX=$(_c LIGHT_YELLOW "$tx_dropped")"
    fi

  done

  _print_section "ROUTING TABLE"

  # Show routing table
  ip route | head -10 | while read -r route; do
    echo "  $route"
  done

  echo ""
  echo "⏱️  Last update: $timestamp"
}
