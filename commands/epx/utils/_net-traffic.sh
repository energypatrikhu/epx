# Real-time network traffic monitoring

__epx_net_traffic__monitor() {
  local iface="${1:-$(ip route | grep default | awk '{print $5}' | head -1)}"

  if [[ -z "$iface" ]]; then
    echo "Error: No network interface specified and no default interface found"
    return 1
  fi

  if [[ ! -e "/sys/class/net/$iface/statistics/rx_bytes" ]]; then
    echo "Error: Interface $iface not found or statistics unavailable"
    return 1
  fi

  clear

  local interval=1
  local samples=60
  local count=0

  declare -a rx_history
  declare -a tx_history

  echo -e "$(_c LIGHT_CYAN "🚀 REAL-TIME TRAFFIC MONITOR — $iface")"
  echo -e "$(_c LIGHT_CYAN "══════════════════════════════════════════════════════════════════════════════")"
  echo "Press Ctrl+C to exit"
  echo ""

  local prev_rx=$(cat /sys/class/net/$iface/statistics/rx_bytes)
  local prev_tx=$(cat /sys/class/net/$iface/statistics/tx_bytes)
  local prev_time=$(date +%s)

  while true; do
    sleep $interval

    local curr_rx=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo $prev_rx)
    local curr_tx=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo $prev_tx)
    local curr_time=$(date +%s)

    local time_diff=$((curr_time - prev_time))
    [[ $time_diff -eq 0 ]] && time_diff=1

    local rx_rate=$(( (curr_rx - prev_rx) / time_diff ))
    local tx_rate=$(( (curr_tx - prev_tx) / time_diff ))

    # Convert to KB/s or MB/s
    local rx_display tx_display rx_unit tx_unit
    if [[ $rx_rate -gt 1048576 ]]; then
      rx_display=$(awk "BEGIN {printf \"%.2f\", $rx_rate/1024/1024}")
      rx_unit="MB/s"
    else
      rx_display=$(awk "BEGIN {printf \"%.2f\", $rx_rate/1024}")
      rx_unit="KB/s"
    fi

    if [[ $tx_rate -gt 1048576 ]]; then
      tx_display=$(awk "BEGIN {printf \"%.2f\", $tx_rate/1024/1024}")
      tx_unit="MB/s"
    else
      tx_display=$(awk "BEGIN {printf \"%.2f\", $tx_rate/1024}")
      tx_unit="KB/s"
    fi

    # Store in history
    rx_history+=($rx_rate)
    tx_history+=($tx_rate)

    # Keep only last N samples
    if [[ ${#rx_history[@]} -gt $samples ]]; then
      rx_history=("${rx_history[@]:1}")
      tx_history=("${tx_history[@]:1}")
    fi

    # Calculate max for scaling
    local max_rx=0
    local max_tx=0
    for rate in "${rx_history[@]}"; do
      [[ $rate -gt $max_rx ]] && max_rx=$rate
    done
    for rate in "${tx_history[@]}"; do
      [[ $rate -gt $max_tx ]] && max_tx=$rate
    done

    [[ $max_rx -eq 0 ]] && max_rx=1
    [[ $max_tx -eq 0 ]] && max_tx=1

    # Create bar graphs
    local rx_bars=$(awk "BEGIN {printf \"%d\", ($rx_rate * 50 / $max_rx)}")
    local tx_bars=$(awk "BEGIN {printf \"%d\", ($tx_rate * 50 / $max_tx)}")
    [[ $rx_bars -gt 50 ]] && rx_bars=50
    [[ $tx_bars -gt 50 ]] && tx_bars=50

    local rx_graph=$(printf '█%.0s' $(seq 1 $rx_bars))
    local tx_graph=$(printf '█%.0s' $(seq 1 $tx_bars))

    # Clear screen and redraw
    clear

    local timestamp=$(date '+%H:%M:%S')
    local total_rx_gb=$(awk "BEGIN {printf \"%.2f\", $curr_rx/1024/1024/1024}")
    local total_tx_gb=$(awk "BEGIN {printf \"%.2f\", $curr_tx/1024/1024/1024}")

    echo -e "$(_c LIGHT_CYAN "🚀 REAL-TIME TRAFFIC MONITOR — $iface")"
    echo -e "$(_c LIGHT_CYAN "══════════════════════════════════════════════════════════════════════════════")"
    echo "Time: $timestamp"
    echo ""
    echo -e "$(_c LIGHT_GREEN "▼ DOWNLOAD: $rx_display $rx_unit")"
    echo "$rx_graph"
    echo ""
    echo -e "$(_c LIGHT_GREEN "▲ UPLOAD:   $tx_display $tx_unit")"
    echo "$tx_graph"
    echo ""
    echo -e "$(_c LIGHT_CYAN "▶ CUMULATIVE TOTALS")"
    echo "Total RX: $(_c LIGHT_GREEN "$total_rx_gb GB")"
    echo "Total TX: $(_c LIGHT_GREEN "$total_tx_gb GB")"
    echo ""
    echo -e "$(_c LIGHT_CYAN "▶ PACKET STATISTICS")"

    local rx_packets=$(cat /sys/class/net/$iface/statistics/rx_packets 2>/dev/null || echo 0)
    local tx_packets=$(cat /sys/class/net/$iface/statistics/tx_packets 2>/dev/null || echo 0)
    local rx_errors=$(cat /sys/class/net/$iface/statistics/rx_errors 2>/dev/null || echo 0)
    local tx_errors=$(cat /sys/class/net/$iface/statistics/tx_errors 2>/dev/null || echo 0)
    local rx_dropped=$(cat /sys/class/net/$iface/statistics/rx_dropped 2>/dev/null || echo 0)
    local tx_dropped=$(cat /sys/class/net/$iface/statistics/tx_dropped 2>/dev/null || echo 0)

    echo "RX Packets: $rx_packets  Errors: $rx_errors  Dropped: $rx_dropped"
    echo "TX Packets: $tx_packets  Errors: $tx_errors  Dropped: $tx_dropped"
    echo ""
    echo "Press Ctrl+C to exit"

    prev_rx=$curr_rx
    prev_tx=$curr_tx
    prev_time=$curr_time
    count=$((count + 1))
  done
}

__epx_net_traffic() {
  local iface="${1:-}"

  if [[ -z "$iface" ]]; then
    # Show available interfaces
    local default_if=$(ip route | grep default | awk '{print $5}' | head -1)
    echo "Available interfaces:"
    ip -o link show | awk -F': ' '{print "  •", $2}'
    echo ""
    echo "Usage: epx net-traffic [interface]"
    echo "Default interface: ${default_if:-none}"
    echo ""

    if [[ -n "$default_if" ]]; then
      read -p "Monitor default interface $default_if? [Y/n] " response
      if [[ "$response" =~ ^[Nn]$ ]]; then
        return 0
      fi
      iface="$default_if"
    else
      return 1
    fi
  fi

  __epx_net_traffic__monitor "$iface"
}
