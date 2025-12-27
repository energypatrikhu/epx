_print_header() {
  local title="$1"
  echo ""
  _c "LIGHT_CYAN" "╔════════════════════════════════════════════════════════╗"
  _c "LIGHT_CYAN" "║  $(_c "LIGHT_YELLOW" "$title")"
  _c "LIGHT_CYAN" "╚════════════════════════════════════════════════════════╝"
}

_print_section() {
  local title="$1"
  echo ""
  _c "LIGHT_GREEN" "▶ $title"
  _c "LIGHT_GREEN" "────────────────────────────────────────────────────────"
}

# List disks with lsblk
_list_disks() {
  if command -v lsblk &> /dev/null; then
    _print_section "Block Devices"
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT -e 7,11,14 --tree
  else
    _c "LIGHT_RED" "lsblk not found"
  fi
}

# List partitions with fdisk and btrfs
_list_partitions() {
  _print_section "Disk Partitions"

  # Show fdisk partitions
  if command -v fdisk &> /dev/null; then
    local disks=$(lsblk -nd -o NAME | grep -E '^(sd|nvme|vd)' | head -10)
    local has_partitions=false

    for disk in $disks; do
      local part_count=$(fdisk -l "/dev/$disk" 2>/dev/null | grep -c "^/dev/")
      if [[ $part_count -gt 0 ]]; then
        has_partitions=true
        _c "WHITE" "  Disk /dev/$disk:"
        fdisk -l "/dev/$disk" 2>/dev/null | grep -E "^/dev/" | while read -r line; do
          _c "WHITE" "    $line"
        done
      fi
    done

    if [[ "$has_partitions" == false ]]; then
      _c "LIGHT_GRAY" "  No partitions found"
    fi
  fi
}

# List RAID status
_list_raids() {
  local raid_found=false

  # Check for mdraid
  if [[ -f /proc/mdstat ]] && grep -q md /proc/mdstat 2>/dev/null; then
    raid_found=true
    _print_section "MD RAID Status"
    local in_device=false
    while IFS= read -r line; do
      if [[ "$line" =~ ^md ]]; then
        in_device=true
        echo ""
        echo "  $line"
      elif [[ "$in_device" == true ]]; then
        if [[ "$line" =~ ^Personalities || "$line" =~ ^unused ]]; then
          in_device=false
        elif [[ -n "$line" ]]; then
          echo "      $line"
        fi
      fi
    done < /proc/mdstat
  fi

  # Check for btrfs filesystems with RAID
  if command -v btrfs &> /dev/null; then
    local btrfs_show=$(btrfs filesystem show 2>/dev/null)
    if [[ -n "$btrfs_show" ]]; then
      # First check if there are any multi-device filesystems
      local has_raid=false
      local uuids=($(echo "$btrfs_show" | grep -oP 'uuid: \K[a-f0-9-]+'))

      for uuid in "${uuids[@]}"; do
        local dev_count=$(echo "$btrfs_show" | grep -A 100 "uuid: $uuid" | grep -c "devid")
        if [[ $dev_count -gt 1 ]]; then
          has_raid=true
          break
        fi
      done

      # Only show section if there's actual RAID
      if [[ "$has_raid" == true ]]; then
        raid_found=true
        _print_section "Btrfs RAID Status"

        for uuid in "${uuids[@]}"; do
          # Get filesystem info
          local fs_info=$(echo "$btrfs_show" | grep -A 100 "uuid: $uuid" | grep -B 1 "uuid: $uuid")
          local label=$(echo "$fs_info" | grep "Label:" | sed 's/.*Label: //;s/ uuid.*//' | tr -d "'" | xargs)

          # Count devices and get mount point
          local devices=()
          local first_device=""
          while IFS= read -r dev_line; do
            if [[ "$dev_line" == *"devid"* ]]; then
              devices+=("$dev_line")
              if [[ -z "$first_device" ]]; then
                first_device=$(echo "$dev_line" | awk '{print $NF}')
              fi
            elif [[ "$dev_line" == *"Label:"* ]] && [[ "$dev_line" != *"$uuid"* ]]; then
              break
            fi
          done < <(echo "$btrfs_show" | grep -A 100 "uuid: $uuid" | tail -n +2)

          local device_count=${#devices[@]}

          # Only show filesystems with multiple devices
          if [[ $device_count -gt 1 ]]; then
            # Find actual mount point from the device
            local mount_point=$(findmnt -n -o TARGET --source "$first_device" 2>/dev/null | head -1)
            if [[ -z "$mount_point" ]]; then
              mount_point=$(grep "$first_device" /proc/mounts 2>/dev/null | awk '{print $2}' | head -1)
            fi

            # Detect RAID level
            local raid_level="unknown"
            if [[ -n "$mount_point" ]] && [[ -d "$mount_point" ]]; then
              local data_profile=$(btrfs filesystem usage "$mount_point" 2>/dev/null | awk '/^Data,/ {sub(/^Data,/, ""); sub(/:.*/, ""); print; exit}')
              if [[ -n "$data_profile" ]]; then
                raid_level=$(echo "$data_profile" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
              fi
            fi

            _c "LIGHT_GREEN" "  ✓ [$raid_level] $label ($device_count devices)"
          fi
        done

        # Show device details only for multi-device filesystems
        for uuid in "${uuids[@]}"; do
          # Count devices for this UUID
          local device_lines=()
          local in_section=false
          while IFS= read -r line; do
            if [[ "$line" == *"uuid: $uuid"* ]]; then
              in_section=true
            elif [[ "$in_section" == true ]]; then
              if [[ "$line" == *"Label:"* ]]; then
                break
              elif [[ "$line" == *"devid"* ]]; then
                device_lines+=("$line")
              fi
            fi
          done <<< "$btrfs_show"

          # Only display if more than 1 device
          if [[ ${#device_lines[@]} -gt 1 ]]; then
            for dev_line in "${device_lines[@]}"; do
              if [[ "$dev_line" == *"missing"* ]]; then
                _c "LIGHT_RED" "    $dev_line"
              else
                _c "WHITE" "    $dev_line"
              fi
            done
          fi
        done
      fi
    fi
  fi

  # Check for LVM
  if command -v lvs &> /dev/null; then
    local lvm_vols=$(lvs --noheadings 2>/dev/null)
    if [[ -n "$lvm_vols" ]]; then
      raid_found=true
      _print_section "LVM Volumes"
      lvs --units=h -o lv_name,lv_size,vg_name,lv_attr 2>/dev/null | while read -r line; do
        if [[ ! "$line" =~ "LV" ]]; then
          _c "WHITE" "  $line"
        fi
      done
    fi
  fi

  # Check for dmraid
  if command -v dmraid &> /dev/null; then
    local dm_raids=$(dmraid -r 2>/dev/null)
    if [[ -n "$dm_raids" ]]; then
      raid_found=true
      _print_section "DM RAID Status"
      dmraid -rr 2>/dev/null | while read -r line; do
        if [[ -n "$line" ]]; then
          _c "WHITE" "  $line"
        fi
      done
    fi
  fi

  # If no RAID found
  if [[ "$raid_found" == false ]]; then
    _print_section "RAID Status"
    _c "LIGHT_GRAY" "  No RAID devices found"
  fi
}

# List disk usage by mount points
_list_usage() {
  _print_section "Disk Usage"

  if command -v df &> /dev/null; then
    df -h 2>/dev/null | tail -n +2 | grep '^/dev/' | sort -k5 -rn 2>/dev/null | head -10 | while read -r line; do
      local usage=$(echo "$line" | awk '{print $5}' | sed 's/%//' 2>/dev/null || echo "0")
      local device=$(echo "$line" | awk '{print $1}')
      local mount=$(echo "$line" | awk '{print $NF}')

      # Color code by usage percentage
      if [[ "$usage" =~ ^[0-9]+$ ]]; then
        local formatted_line=$(printf "  %-30s %5s%%   %s" "$device" "$usage" "$mount")
        if (( usage >= 90 )); then
          _c "LIGHT_RED" "$formatted_line"
        elif (( usage >= 75 )); then
          _c "LIGHT_YELLOW" "$formatted_line"
        else
          echo "$formatted_line"
        fi
      fi
    done
  fi
}

# List smartctl info if available
_list_smart() {
  if command -v smartctl &> /dev/null; then
    _print_section "SMART Status"

    local disks=$(smartctl --scan 2>/dev/null | grep '/dev/' | awk '{print $1}' | head -5)
    if [[ -n "$disks" ]]; then
      for disk in $disks; do
        local health=$(smartctl -H "$disk" 2>/dev/null | grep -i "overall-health" | awk '{print $NF}')
        if [[ "$health" == "PASSED" ]]; then
          echo -n "  ✓ $disk - "
          _c "LIGHT_GREEN" "$health"
        elif [[ "$health" == "FAILED" ]]; then
          echo -n "  ✗ $disk - "
          _c "LIGHT_RED" "$health"
        elif [[ -n "$health" ]]; then
          echo "  $disk - $health"
        else
          echo "  $disk"
        fi
      done
    else
      _c "LIGHT_GRAY" "  No SMART devices found"
    fi
  fi
}

# Main execution
_print_header "📦 DISK & RAID INFORMATION"
_list_disks || true
_list_partitions || true
_list_raids || true
_list_usage || true
_list_smart || true
echo ""
