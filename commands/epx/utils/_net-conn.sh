#!/bin/bash

# Network connections detailed view
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
__epx_net_conn() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  clear
  echo "╭────────────────────────────────────────────────────────────╮"
  echo "│ 🔌 NETWORK CONNECTIONS                                       │"
  echo "├────────────────────────────────────────────────────────────┤"

  # Connection summary
  echo "│ CONNECTION SUMMARY                                          │"
  echo "│                                                             │"

  local total=$(ss -tan | tail -n +2 | wc -l)
  local established=$(ss -tan | grep ESTAB | wc -l)
  local listen=$(ss -tln | grep LISTEN | wc -l)
  local syn_sent=$(ss -tan | grep SYN-SENT | wc -l)
  local syn_recv=$(ss -tan | grep SYN-RECV | wc -l)
  local fin_wait=$(ss -tan | grep FIN-WAIT | wc -l)
  local time_wait=$(ss -tan | grep TIME-WAIT | wc -l)
  local close_wait=$(ss -tan | grep CLOSE-WAIT | wc -l)

  printf "│ Total connections : %-40d │\n" "$total"
  printf "│ ESTABLISHED       : %-40d │\n" "$established"
  printf "│ LISTEN            : %-40d │\n" "$listen"
  printf "│ SYN-SENT          : %-40d │\n" "$syn_sent"
  printf "│ SYN-RECV          : %-40d │\n" "$syn_recv"
  printf "│ FIN-WAIT          : %-40d │\n" "$fin_wait"
  printf "│ TIME-WAIT         : %-40d │\n" "$time_wait"
  printf "│ CLOSE-WAIT        : %-40d │\n" "$close_wait"

  echo "│                                                             │"
  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ TOP REMOTE IPs (by connection count)                       │"
  echo "│                                                             │"

  # Top remote IPs
  ss -tan | grep ESTAB | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -10 | while read count ip; do
    local hostname=$(getent hosts "$ip" 2>/dev/null | awk '{print $2}' | head -1)
    if [[ -z "$hostname" ]]; then
      hostname="Unknown"
    fi
    printf "│ %3d × %-15s  %-32s │\n" "$count" "$ip" "(${hostname:0:30})"
  done

  echo "│                                                             │"
  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ LISTENING SERVICES                                          │"
  echo "│                                                             │"

  # Listening services
  ss -tlnp 2>/dev/null | grep LISTEN | awk '{print $4, $6}' | sort -t: -k2 -n | head -15 | while read addr process; do
    local port=$(echo "$addr" | awk -F: '{print $NF}')
    local ip=$(echo "$addr" | awk -F: '{print $(NF-1)}')
    [[ "$ip" == "0.0.0.0" || "$ip" == "*" ]] && ip="All"
    [[ "$ip" == "::" ]] && ip="All(v6)"

    local proc_name=$(echo "$process" | grep -o 'users:(([^,]*' | cut -d'(' -f3 | tr -d '"')
    [[ -z "$proc_name" ]] && proc_name="Unknown"

    printf "│ Port %-5s on %-10s → %-30s │\n" "$port" "$ip" "${proc_name:0:28}"
  done

  echo "│                                                             │"
  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ ACTIVE CONNECTIONS (top 15)                                │"
  echo "│                                                             │"

  # Active connections
  ss -tanp 2>/dev/null | grep ESTAB | head -15 | while read -r line; do
    local local_addr=$(echo "$line" | awk '{print $4}')
    local remote_addr=$(echo "$line" | awk '{print $5}')
    local process=$(echo "$line" | awk '{print $6}' | grep -o 'users:(([^,]*' | cut -d'(' -f3 | tr -d '"')

    [[ -z "$process" ]] && process="?"

    local local_port=$(echo "$local_addr" | awk -F: '{print $NF}')
    local remote_ip=$(echo "$remote_addr" | cut -d: -f1)
    local remote_port=$(echo "$remote_addr" | awk -F: '{print $NF}')

    printf "│ %-12s :%-5s ↔ %-15s:%-5s         │\n" \
      "${process:0:12}" "$local_port" "${remote_ip:0:15}" "$remote_port"
  done

  echo "│                                                             │"
  echo "├────────────────────────────────────────────────────────────┤"
  echo "│ UDP CONNECTIONS                                             │"
  echo "│                                                             │"

  # UDP connections
  local udp_count=$(ss -uan | tail -n +2 | wc -l)
  printf "│ Total UDP sockets : %-40d │\n" "$udp_count"
  echo "│                                                             │"

  ss -ulnp 2>/dev/null | grep -v 'State' | head -10 | while read -r line; do
    local addr=$(echo "$line" | awk '{print $4}')
    local port=$(echo "$addr" | awk -F: '{print $NF}')
    local process=$(echo "$line" | awk '{print $6}' | grep -o 'users:(([^,]*' | cut -d'(' -f3 | tr -d '"')

    [[ -z "$process" ]] && process="Unknown"

    printf "│ Port %-5s → %-46s │\n" "$port" "${process:0:44}"
  done

  echo "│                                                             │"
  echo "├────────────────────────────────────────────────────────────┤"
  printf "│ ⏱️  Last update: %-43s │\n" "$timestamp"
  echo "│ Tip: Use 'watch -n1 ss -tan' for live monitoring            │"
  echo "╰────────────────────────────────────────────────────────────╯"
}
