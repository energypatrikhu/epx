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
    local btrfs_output=$(btrfs filesystem show 2>/dev/null)
    if [[ -n "$btrfs_output" ]]; then
      raid_found=true
      _print_section "Btrfs RAID Status"

      # Build array of unique filesystems
      local -a processed_uuids
      while IFS= read -r line; do
        if [[ "$line" =~ "Label:" ]]; then
          local uuid=$(echo "$line" | grep -oP 'uuid: \K[^ ]+')

          # Skip if we already processed this uuid
          if [[ " ${processed_uuids[*]} " =~ " ${uuid} " ]]; then
            continue
          fi
          processed_uuids+=("$uuid")

          local label=$(echo "$line" | grep -oP "Label: '\K[^']+|Label: \K\S+")

          # Count devices for this specific filesystem
          local device_count=$(echo "$btrfs_output" | grep -A 1 "uuid: $uuid" | grep -c "devid")

          # Get RAID level dynamically
          local raid_level="single"
          local mount_point=$(btrfs filesystem show "$uuid" 2>/dev/null | grep "path" | head -1 | grep -oP 'path \K/[^ ]+')

          if [[ -n "$mount_point" && -d "$mount_point" ]]; then
            raid_level=$(btrfs filesystem usage "$mount_point" 2>/dev/null | grep -E "Data.*:" | head -1 | grep -oP '(raid0|raid1|raid10|raid1c3|raid1c4|single|dup)' || echo "single")
          fi

          if [[ $device_count -gt 1 ]] || [[ "$raid_level" != "single" ]]; then
            _c "LIGHT_GREEN" "  ✓ [$raid_level] $label ($device_count devices)"
          else
            _c "WHITE" "  • [$raid_level] $label"
          fi
        fi
      done <<< "$btrfs_output"

      # Show device details
      echo ""
      echo "$btrfs_output" | while IFS= read -r line; do
        if [[ "$line" =~ "devid" ]]; then
          if [[ "$line" =~ "missing" ]]; then
            _c "LIGHT_RED" "    $line"
          else
            _c "WHITE" "    $line"
          fi
        fi
      done
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
    df -h | tail -n +2 | sort -k5 -rn | head -10 | while read -r line; do
      local usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
      local device=$(echo "$line" | awk '{print $1}')
      local mount=$(echo "$line" | awk '{print $NF}')

      # Color code by usage percentage
      if (( usage >= 90 )); then
        _c "LIGHT_RED" "  $(_c "LIGHT_RED" "$device") $(printf '%3d%%' $usage) - $mount"
      elif (( usage >= 75 )); then
        _c "LIGHT_YELLOW" "  $(_c "LIGHT_YELLOW" "$device") $(printf '%3d%%' $usage) - $mount"
      else
        _c "LIGHT_GREEN" "  $(_c "LIGHT_GREEN" "$device") $(printf '%3d%%' $usage) - $mount"
      fi
    done
  fi
}

# List smartctl info if available
_list_smart() {
  if command -v smartctl &> /dev/null; then
    _print_section "SMART Status"

    local disks=$(smartctl --scan | grep '/dev/' | awk '{print $1}' | head -5)
    if [[ -n "$disks" ]]; then
      for disk in $disks; do
        local health=$(smartctl -H "$disk" 2>/dev/null | grep -i "overall-health" | awk '{print $NF}')
        if [[ "$health" == "PASSED" ]]; then
          _c "LIGHT_GREEN" "  $(_c "LIGHT_GREEN" "✓") $disk - $health"
        elif [[ "$health" == "FAILED" ]]; then
          _c "LIGHT_RED" "  $(_c "LIGHT_RED" "✗") $disk - $health"
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
_list_disks
_list_partitions
_list_raids
_list_usage
_list_smart
echo ""
