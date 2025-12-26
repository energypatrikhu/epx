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
        _c "LIGHT_BLUE" "  Disk /dev/$disk:"
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
    while IFS= read -r line; do
      if [[ "$line" =~ ^md ]]; then
        _c "LIGHT_BLUE" "  $line"
      elif [[ -n "$line" && ! "$line" =~ ^unused ]]; then
        _c "WHITE" "    $line"
      fi
    done < /proc/mdstat
  fi

  # Check for btrfs filesystems with RAID
  if command -v btrfs &> /dev/null; then
    local btrfs_output=$(btrfs filesystem show 2>/dev/null || true)
    if [[ -n "$btrfs_output" ]]; then
      raid_found=true
      _print_section "Btrfs RAID Status"

      # Process filesystems
      local current_uuid=""
      local current_label=""
      local device_count=0
      local mount_point=""

      while IFS= read -r line; do
        if [[ "$line" == *"Label:"* ]]; then
          # Print previous filesystem if exists
          if [[ -n "$current_uuid" ]]; then
            local raid_level="single"
            if [[ -n "$mount_point" && -d "$mount_point" ]]; then
              local usage_output=$(btrfs filesystem usage "$mount_point" 2>/dev/null || true)
              local data_line=$(echo "$usage_output" | grep "^Data," | head -1)
              if [[ -n "$data_line" ]]; then
                # Extract text between "Data," and ":" - e.g., "Data,RAID1:" -> "RAID1"
                raid_level=$(echo "$data_line" | cut -d',' -f2 | cut -d':' -f1 | tr -d ' ' | tr '[:upper:]' '[:lower:]')
              fi
              [[ -z "$raid_level" ]] && raid_level="single"
            fi
            if [[ $device_count -gt 1 ]] || [[ "$raid_level" != "single" ]]; then
              _c "LIGHT_GREEN" "  ✓ [$raid_level] $current_label ($device_count devices)"
            else
              _c "WHITE" "  • [$raid_level] $current_label"
            fi
          fi

          # Start new filesystem - extract uuid and label with sed
          current_uuid=$(echo "$line" | sed "s/.*uuid: //;s/ .*//" 2>/dev/null || true)
          current_label=$(echo "$line" | sed "s/.*Label: //;s/ uuid.*//" | sed "s/'//g" 2>/dev/null || true)
          device_count=0
          mount_point=""
        elif [[ "$line" == *"devid"* ]]; then
          ((device_count++)) || true
          if [[ -z "$mount_point" ]]; then
            mount_point=$(echo "$line" | sed 's/.*path //' 2>/dev/null || true)
          fi
        fi
      done <<< "$btrfs_output"

      # Print last filesystem
      if [[ -n "$current_uuid" ]]; then
        local raid_level="single"
        if [[ -n "$mount_point" && -d "$mount_point" ]]; then
          local usage_output=$(btrfs filesystem usage "$mount_point" 2>/dev/null || true)
          local data_line=$(echo "$usage_output" | grep "^Data," | head -1)
          if [[ -n "$data_line" ]]; then
            # Extract text between "Data," and ":" - e.g., "Data,RAID1:" -> "RAID1"
            raid_level=$(echo "$data_line" | cut -d',' -f2 | cut -d':' -f1 | tr -d ' ' | tr '[:upper:]' '[:lower:]')
          fi
          [[ -z "$raid_level" ]] && raid_level="single"
        fi
        if [[ $device_count -gt 1 ]] || [[ "$raid_level" != "single" ]]; then
          _c "LIGHT_GREEN" "  ✓ [$raid_level] $current_label ($device_count devices)"
        else
          _c "WHITE" "  • [$raid_level] $current_label"
        fi
      fi

      # Show device details
      echo ""
      while IFS= read -r line; do
        if [[ "$line" == *"devid"* ]]; then
          if [[ "$line" == *"missing"* ]]; then
            _c "LIGHT_RED" "    $line"
          else
            _c "WHITE" "    $line"
          fi
        fi
      done <<< "$btrfs_output" || true
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
  _print_section "Disk Usage (Top Mounts)"

  if command -v df &> /dev/null; then
    df -h 2>/dev/null | tail -n +2 | sort -k5 -rn 2>/dev/null | head -10 | while read -r line; do
      local usage=$(echo "$line" | awk '{print $5}' | sed 's/%//' 2>/dev/null || echo "0")
      local device=$(echo "$line" | awk '{print $1}')
      local mount=$(echo "$line" | awk '{print $NF}')

      # Color code by usage percentage
      if [[ "$usage" =~ ^[0-9]+$ ]]; then
        if (( usage >= 90 )); then
          _c "LIGHT_RED" "  $device $(printf '%3d%%' $usage) - $mount"
        elif (( usage >= 75 )); then
          _c "LIGHT_YELLOW" "  $device $(printf '%3d%%' $usage) - $mount"
        else
          _c "LIGHT_GREEN" "  $device $(printf '%3d%%' $usage) - $mount"
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
          _c "LIGHT_GREEN" "  ✓ $disk - $health"
        elif [[ "$health" == "FAILED" ]]; then
          _c "LIGHT_RED" "  ✗ $disk - $health"
        elif [[ -n "$health" ]]; then
          _c "WHITE" "  $disk - $health"
        else
          _c "WHITE" "  $disk"
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
