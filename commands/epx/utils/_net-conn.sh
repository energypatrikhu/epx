# Network connections detailed view

__epx_net_conn() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  clear
  echo "🔌 NETWORK CONNECTIONS"
  echo "═══════════════════════════════════════════════════════════════════════════════"

  # Connection summary
  _print_section "CONNECTION SUMMARY"

  local total=$(ss -tan | tail -n +2 | wc -l)
  local established=$(ss -tan | grep ESTAB | wc -l)
  local listen=$(ss -tln | grep LISTEN | wc -l)
  local syn_sent=$(ss -tan | grep SYN-SENT | wc -l)
  local syn_recv=$(ss -tan | grep SYN-RECV | wc -l)
  local fin_wait=$(ss -tan | grep FIN-WAIT | wc -l)
  local time_wait=$(ss -tan | grep TIME-WAIT | wc -l)
  local close_wait=$(ss -tan | grep CLOSE-WAIT | wc -l)

  echo "  Total connections : $total"
  echo "  ESTABLISHED       : $established"
  echo "  LISTEN            : $listen"
  echo "  SYN-SENT          : $syn_sent"
  echo "  SYN-RECV          : $syn_recv"
  echo "  FIN-WAIT          : $fin_wait"
  echo "  TIME-WAIT         : $time_wait"
  echo "  CLOSE-WAIT        : $close_wait"

  _print_section "TOP REMOTE IPs (by connection count)"

  # Top remote IPs
  ss -tan | grep ESTAB | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -10 | while read count ip; do
    local hostname=$(getent hosts "$ip" 2>/dev/null | awk '{print $2}' | head -1)
    if [[ -z "$hostname" ]]; then
      hostname="Unknown"
    fi
    printf "  %3d × %-15s  %-32s\n" "$count" "$ip" "(${hostname:0:30})"
  done

  _print_section "LISTENING SERVICES"

  # Listening services
  ss -tlnp 2>/dev/null | grep LISTEN | awk '{print $4, $6}' | sort -t: -k2 -n | head -15 | while read addr process; do
    local port=$(echo "$addr" | awk -F: '{print $NF}')
    local ip=$(echo "$addr" | awk -F: '{print $(NF-1)}')
    [[ "$ip" == "0.0.0.0" || "$ip" == "*" ]] && ip="All"
    [[ "$ip" == "::" ]] && ip="All(v6)"

    local proc_name=$(echo "$process" | grep -o 'users:(([^,]*' | cut -d'(' -f3 | tr -d '"')
    [[ -z "$proc_name" ]] && proc_name="Unknown"

    printf "  Port %-5s on %-10s → %-30s\n" "$port" "$ip" "${proc_name:0:28}"
  done

  _print_section "ACTIVE CONNECTIONS (top 15)"

  # Active connections
  ss -tanp 2>/dev/null | grep ESTAB | head -15 | while read -r line; do
    local local_addr=$(echo "$line" | awk '{print $4}')
    local remote_addr=$(echo "$line" | awk '{print $5}')
    local process=$(echo "$line" | awk '{print $6}' | grep -o 'users:(([^,]*' | cut -d'(' -f3 | tr -d '"')

    [[ -z "$process" ]] && process="?"

    local local_port=$(echo "$local_addr" | awk -F: '{print $NF}')
    local remote_ip=$(echo "$remote_addr" | cut -d: -f1)
    local remote_port=$(echo "$remote_addr" | awk -F: '{print $NF}')

    printf "  %-12s :%-5s ↔ %-15s:%-5s\n" \
      "${process:0:12}" "$local_port" "${remote_ip:0:15}" "$remote_port"
  done

  _print_section "UDP CONNECTIONS"

  # UDP connections
  local udp_count=$(ss -uan | tail -n +2 | wc -l)
  echo "  Total UDP sockets : $udp_count"

  ss -ulnp 2>/dev/null | grep -v 'State' | head -10 | while read -r line; do
    local addr=$(echo "$line" | awk '{print $4}')
    local port=$(echo "$addr" | awk -F: '{print $NF}')
    local process=$(echo "$line" | awk '{print $6}' | grep -o 'users:(([^,]*' | cut -d'(' -f3 | tr -d '"')

    [[ -z "$process" ]] && process="Unknown"

    printf "  Port %-5s → %-46s\n" "$port" "${process:0:44}"
  done

  echo ""
  echo "⏱️  Last update: $timestamp"
  echo "Tip: Use 'watch -n1 ss -tan' for live monitoring"
}
