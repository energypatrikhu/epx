#!/bin/bash

__epx_backup_copy() {
  local input_path=$1
  local output_path=$2
  local excluded_array=$3

  rsync -rxzvuahP --stats --exclude-from=<(for i in "${excluded_array[@]}"; do echo "$i"; done) "$input_path/" "$output_path"
}

__epx_backup_compress() {
  local input_dir=$1
  local output_path=$2
  local backup_dir=$3

  tar -I "zstd -T0 --ultra -22 -v --auto-threads=logical --long -M8192" -cf "${backup_dir}.tar.zst" -C "$output_path" "$input_dir"
}

__epx_backup() {
  local input_path=$1
  local output_path=$2
  local num_of_backups=$3
  local excluded=$4

  if [ -z "$input_path" ] || [ -z "$output_path" ] || [ -z "$num_of_backups" ]; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Usage: backup <input_path> <output_path> <num_of_backups> [excluded directories, files separated with (,)]")"
  fi

  local current_timestamp=$(date "+%Y-%m-%d_%H-%M-%S")

  if [ -z "$excluded" ]; then
    excluded=""
  fi

  mapfile -t excluded_array < <(echo "$excluded" | tr "," "\n")

  printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Starting backup...")"

  printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Stopping all beesd processes...")"
  systemctl stop beesd@* || true

  local backup_dir="$output_path/$current_timestamp"

  printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Creating backup directory: $backup_dir")"
  mkdir -p "$backup_dir"

  printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Copying files...")"
  __epx_backup_copy "$input_path" "$backup_dir" "${excluded_array[@]}"

  printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Compressing files...")"
  __epx_backup_compress "$current_timestamp" "$output_path" "$backup_dir"

  printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Removing backup directory: $backup_dir")"
  rm -rf "$backup_dir"

  printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Removing old backups...")"
  mapfile -t backups < <(find "$output_path" -maxdepth 1 -name "*.tar.zst" -printf "%f\n" | sort -r | tail -n +$((num_of_backups + 1)))
  for backup in "${backups[@]}"; do
    printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Removing backup: $output_path/$backup")"
    rm -f "$output_path/$backup"
  done

  printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Starting all beesd processes...")"
  systemctl start beesd@* --all || true
}
