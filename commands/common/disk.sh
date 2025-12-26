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
    local btrfs_show=$(btrfs filesystem show 2>/dev/null)
    if [[ -n "$btrfs_show" ]]; then
      raid_found=true
      _print_section "Btrfs RAID Status"

      # Extract unique filesystem UUIDs
      local uuids=($(echo "$btrfs_show" | grep -oP 'uuid: \K[a-f0-9-]+'))

      for uuid in "${uuids[@]}"; do
        # Get filesystem info
        local fs_info=$(echo "$btrfs_show" | grep -A 100 "uuid: $uuid" | grep -B 1 "uuid: $uuid")
        local label=$(echo "$fs_info" | grep "Label:" | sed 's/.*Label: //;s/ uuid.*//' | tr -d "'")

        # Count devices and get mount point
        local devices=()
        local mount_point=""
        while IFS= read -r dev_line; do
          if [[ "$dev_line" == *"devid"* ]]; then
            devices+=("$dev_line")
            if [[ -z "$mount_point" ]]; then
              mount_point=$(echo "$dev_line" | awk '{print $NF}')
            fi
          elif [[ "$dev_line" == *"Label:"* ]] && [[ "$dev_line" != *"$uuid"* ]]; then
            break
          fi
        done < <(echo "$btrfs_show" | grep -A 100 "uuid: $uuid" | tail -n +2)

        local device_count=${#devices[@]}

        # Detect RAID level
        local raid_level="single"
        if [[ -n "$mount_point" ]] && [[ -e "$mount_point" ]]; then
          local data_profile=$(btrfs filesystem usage "$mount_point" 2>/dev/null | awk '/^Data,/ {sub(/^Data,/, ""); sub(/:.*/, ""); print; exit}')
          if [[ -n "$data_profile" ]]; then
            raid_level=$(echo "$data_profile" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
          fi
        fi

        # Display filesystem info
        if [[ $device_count -gt 1 ]] || [[ "$raid_level" != "single" ]]; then
          _c "LIGHT_GREEN" "  ✓ [$raid_level] $label ($device_count devices)"
        else
          _c "WHITE" "  • [$raid_level] $label"
        fi
      done

      # Show device details
      echo ""
      echo "$btrfs_show" | while IFS= read -r line; do
        if [[ "$line" == *"devid"* ]]; then
          if [[ "$line" == *"missing"* ]]; then
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
