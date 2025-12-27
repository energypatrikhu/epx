#!/bin/bash

# Network interfaces detailed view
# Border width configuration
BORDER_WIDTH=60
BORDER_CONTENT_WIDTH=$((BORDER_WIDTH - 2))

# Helper to print top border
_print_top() {
  printf "╭%s╮\n" "$(printf '─%.0s' $(seq 1 $BORDER_CONTENT_WIDTH))"
}

# Helper to print separator
_print_separator() {
  printf "├%s┤\n" "$(printf '─%.0s' $(seq 1 $BORDER_CONTENT_WIDTH))"
}

# Helper to print bottom border
_print_bottom() {
  printf "╰%s╯\n" "$(printf '─%.0s' $(seq 1 $BORDER_CONTENT_WIDTH))"
}
__epx_net_if() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  clear
  echo "╭────────────────────────────────────────────────────────────╮"
  echo "│ 📡 NETWORK INTERFACES                                        │"
  echo "├────────────────────────────────────────────────────────────┤"

  # Iterate through all network interfaces
  for iface in $(ip -o link show | awk -F': ' '{print $2}'); do
    local state=$(ip link show "$iface" 2>/dev/null | grep -o 'state [A-Z]*' | awk '{print $2}')
    local mtu=$(ip link show "$iface" 2>/dev/null | grep -o 'mtu [0-9]*' | awk '{print $2}')
    local mac=$(ip link show "$iface" 2>/dev/null | grep -o 'link/ether [^ ]*' | awk '{print $2}')

    # Get IPv4 addresses
    local ipv4_addrs=$(ip -4 addr show "$iface" 2>/dev/null | grep inet | awk '{print $2}')

    # Get IPv6 addresses
    local ipv6_addrs=$(ip -6 addr show "$iface" 2>/dev/null | grep inet6 | grep -v 'scope link' | awk '{print $2}')

    echo "│                                                             │"
    printf "│ ┌─ %-57s │\n" "$iface"
    printf "│ │  State      : %-46s │\n" "$state"
    printf "│ │  MTU        : %-46s │\n" "${mtu:-N/A}"

    if [[ -n "$mac" ]]; then
      printf "│ │  MAC        : %-46s │\n" "$mac"
    fi

    # Speed and duplex (only for physical interfaces)
    if [[ "$iface" != "lo" ]] && command -v ethtool &>/dev/null; then
      local speed=$(ethtool "$iface" 2>/dev/null | grep Speed | awk '{print $2}')
      local duplex=$(ethtool "$iface" 2>/dev/null | grep Duplex | awk '{print $2}')

      if [[ -n "$speed" ]]; then
        printf "│ │  Speed      : %-46s │\n" "$speed"
      fi

      if [[ -n "$duplex" ]]; then
        printf "│ │  Duplex     : %-46s │\n" "$duplex"
      fi
    fi

    # IPv4 addresses
    if [[ -n "$ipv4_addrs" ]]; then
      echo "│ │                                                           │"
      echo "│ │  IPv4 Addresses:                                          │"
      while IFS= read -r addr; do
        printf "│ │    • %-52s │\n" "$addr"
      done <<< "$ipv4_addrs"
    fi

    # IPv6 addresses
    if [[ -n "$ipv6_addrs" ]]; then
      echo "│ │                                                           │"
      echo "│ │  IPv6 Addresses:                                          │"
      while IFS= read -r addr; do
        printf "│ │    • %-52s │\n" "$addr"
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

      echo "│ │                                                           │"
      echo "│ │  Statistics:                                              │"
      printf "│ │    RX: %-5s GB (%-10s packets)                  │\n" "$rx_gb" "$rx_packets"
      printf "│ │    TX: %-5s GB (%-10s packets)                  │\n" "$tx_gb" "$tx_packets"
      printf "│ │    Errors: RX=%-5s TX=%-5s                         │\n" "$rx_errors" "$tx_errors"
      printf "│ │    Dropped: RX=%-5s TX=%-5s                        │\n" "$rx_dropped" "$tx_dropped"
    fi

    echo "│ └─────────────────────────────────────────────────────────  │"
  done

  echo "│                                                             │"
  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ ROUTING TABLE                                               │"
  echo "│                                                             │"

  # Show routing table
  ip route | head -10 | while read -r route; do
    printf "│ %s │\n" "$(printf '%-59s' "$route")"
  done

  echo "├────────────────────────────────────────────────────────────┤"
  printf "│ ⏱️  Last update: %-43s │\n" "$timestamp"
  echo "╰────────────────────────────────────────────────────────────╯"
}
