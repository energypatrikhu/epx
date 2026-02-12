# Network scanner utility - discovers devices on local network

__epx_net_scan() {
  local interface="${1:-}"
  local timeout=1

  # If no interface specified, get the default one
  if [[ -z "$interface" ]]; then
    interface=$(ip route | grep default | awk '{print $5}' | head -1)
    if [[ -z "$interface" ]]; then
      echo -e "$(_c LIGHT_RED "Error"): Could not determine default network interface"
      return 1
    fi
  fi

  # Get the network in CIDR format
  local network=$(ip -4 addr show "$interface" 2>/dev/null | grep inet | awk '{print $2}')
  if [[ -z "$network" ]]; then
    echo -e "$(_c LIGHT_RED "Error"): Could not get network information for interface $(_c LIGHT_YELLOW "$interface")"
    return 1
  fi

  local ip_addr=$(echo "$network" | cut -d'/' -f1)
  local cidr=$(echo "$network" | cut -d'/' -f2)
  local subnet=$(echo "$ip_addr" | sed "s/\.[0-9]*$/\.0/" | sed "s/\.[0-9]*\.[0-9]*$/\.0\.0/")

  clear
  echo -e "$(_c LIGHT_CYAN "NETWORK SCANNER")"
  echo -e "$(_c LIGHT_CYAN "═════════════════════════════════════════════════════════════════════════════")"
  echo ""
  echo "  Interface  : $(_c LIGHT_GREEN "$interface")"
  echo "  Network    : $(_c LIGHT_BLUE "$network")"
  echo "  Gateway IP : $(_c LIGHT_YELLOW "$(ip route | grep default | awk '{print $3}' | head -1)")"
  echo ""
  echo -e "$(_c LIGHT_CYAN "Scanning for devices...")"
  echo ""

  local devices=()
  local count=0

  # Determine the range based on CIDR notation
  local base_ip=$(echo "$ip_addr" | cut -d'.' -f1-3)
  local start=1
  local end=254

  if [[ "$cidr" == "32" || "$cidr" == "31" ]]; then
    echo -e "$(_c LIGHT_YELLOW "Warning"): Network is too small to scan meaningfully"
    return 0
  fi

  # Create a temp file for parallel results
  local temp_file=$(mktemp)

  # Scan all IPs in the subnet
  for i in $(seq $start $end); do
    local target_ip="$base_ip.$i"

    # Ping in background with timeout
    (
      if ping -c 1 -W $timeout "$target_ip" &>/dev/null; then
        local hostname=$(getent hosts "$target_ip" 2>/dev/null | awk '{print $2}' | head -1)
        if [[ -z "$hostname" ]]; then
          hostname=$(timeout 2 nslookup "$target_ip" 2>/dev/null | grep 'name =' | awk '{print $NF}' | sed 's/\.$//')
        fi
        if [[ -z "$hostname" ]]; then
          hostname=$(timeout 1 bash -c "cat /etc/hosts | grep -w $target_ip | awk '{print \$2}'" 2>/dev/null | head -1)
        fi
        if [[ -z "$hostname" ]]; then
          hostname="N/A"
        fi
        echo "$target_ip|$hostname" >> "$temp_file"
      fi
    ) &

    # Limit parallel processes to avoid overwhelming the system
    if [[ $((i % 16)) -eq 0 ]]; then
      wait
    fi
  done

  wait

  # Read and display results
  if [[ -f "$temp_file" ]]; then
    local devices=()
    while IFS='|' read -r ip hostname; do
      devices+=("$ip|$hostname")
    done < "$temp_file"

    if [[ ${#devices[@]} -eq 0 ]]; then
      echo -e "$(_c LIGHT_YELLOW "No devices found on network")"
    else
      echo "  Found $(_c LIGHT_GREEN "${#devices[@]}") device(s):"
      echo ""
      echo -e "  $(_c LIGHT_CYAN "IP Address")\t\t$(_c LIGHT_CYAN "Hostname")"
      echo -e "  $(_c LIGHT_CYAN "──────────────────────────────────────────────────────────────────────────")"

      for device in "${devices[@]}"; do
        local dev_ip=$(echo "$device" | cut -d'|' -f1)
        local dev_host=$(echo "$device" | cut -d'|' -f2)

        # Check if it's the gateway
        local gw=$(ip route | grep default | awk '{print $3}')
        if [[ "$dev_ip" == "$gw" ]]; then
          dev_host="$dev_host (Gateway)"
        fi

        # Check if it's the local machine
        if [[ "$dev_ip" == "$ip_addr" ]]; then
          dev_host="$dev_host (Local)"
        fi

        printf "  $(_c LIGHT_BLUE "%s")\t\t$(_c LIGHT_GREEN "%s")\n" "$dev_ip" "$dev_host"
      done
      echo ""
    fi

    rm -f "$temp_file"
  fi

  echo -e "$(_c LIGHT_CYAN "═════════════════════════════════════════════════════════════════════════════")"
  echo ""
}
