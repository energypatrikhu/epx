#!/bin/bash

__epx_backup__log_status_to_file() {
  local status=$1
  local logfile=$2
  local input_path=$3
  local output_path=$4
  local output_zst_file=$5
  local starting_date=$6
  local backups_to_keep=$7

  local current_date=$(date -d "$starting_date" "+%Y. %m. %d %H:%M:%S")
  local backup_size="N/A"
  local num_of_backups=$(find "$output_path" -maxdepth 1 -name "*.tar.zst" -printf "%f\n" | wc -l)

  if [ -f "$output_zst_file" ]; then
    backup_size=$(du -h "$output_zst_file" | awk '{print $1}')
  fi

  # Get the size of the backup directory, exclude log file
  local total_size=$(du -h --exclude="backup-info.log" "$output_path" | awk '{print $1}')

  echo "$status (${input_path}) (${backup_size}) (${total_size}) (${num_of_backups}/${backups_to_keep}) (${current_date})" >"$logfile"

  # Start all beesd processes after creating a backup
  printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Starting all beesd processes...")"
  systemctl start beesd@* --all || true
}

__epx_backup__copy() {
  local input_path=$1
  local output_path=$2
  local excluded_array=$3

  # Copy files to the backup directory via rsync
  rsync -avzP --stats --exclude-from=<(for i in "${excluded_array[@]}"; do echo "$i"; done) "$input_path/" "$output_path"
  if [ $? -ne 0 ]; then
    return 1
  fi
  return 0
}

__epx_backup__compress() {
  local input_dir=$1
  local output_path=$2
  local backup_file=$3

  # Compress the backup directory with tar and zstd (ultra compression)
  tar -I "zstd -T0 --ultra -22 -v --auto-threads=logical --long -M8192" -cf "${backup_file}" -C "$output_path" "$input_dir"
  if [ $? -ne 0 ]; then
    return 1
  fi
  return 0
}

__epx_backup() {
  local input_path=$1
  local output_path=$2
  local backups_to_keep=$3
  local excluded=$4

  # Stop the script if any of the required arguments are missing
  if [ -z "$input_path" ] || [ -z "$output_path" ] || [ -z "$backups_to_keep" ]; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Usage: backup <input path> <output path> <backups to keep> [excluded directories, files separated with (,)]")"
    return 1
  fi

  # Save the starting date and current timestamp
  local starting_date=$(date +"%Y-%m-%d %H:%M:%S")
  local current_timestamp=$(date -d "$starting_date" "+%Y-%m-%d_%H-%M-%S")

  # Set backup info variables
  local backup_info="$output_path/backup-info.log"
  local backup_dir="$output_path/$current_timestamp"
  local backup_file="$backup_dir.tar.zst"

  # Create an array of excluded directories and files
  mapfile -t excluded_array < <(echo "$excluded" | tr "," "\n")

  printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Starting backup...")"

  # Stop all beesd processes before creating a backup
  printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Stopping all beesd processes...")"
  systemctl stop beesd@* || true

  # Create the backup directory
  printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Creating backup directory: $backup_dir")"
  if ! mkdir -p "$backup_dir"; then
    __epx_backup__log_status_to_file "Backup failed, failed to create backup directory" "$backup_info" "$input_path" "$output_path" "$backup_file" "$starting_date" "$backups_to_keep"
    return 1
  fi

  # Copy files to the backup directory
  printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Copying files...")"
  if ! __epx_backup__copy "$input_path" "$backup_dir" "${excluded_array[@]}"; then
    __epx_backup__log_status_to_file "Backup failed, failed to copy files" "$backup_info" "$input_path" "$output_path" "$backup_file" "$starting_date" "$backups_to_keep"
    return 1
  fi

  # Compress the backup directory
  printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Compressing files...")"
  if ! __epx_backup__compress "$current_timestamp" "$output_path" "$backup_file"; then
    __epx_backup__log_status_to_file "Backup failed, failed to compress files" "$backup_info" "$input_path" "$output_path" "$backup_file" "$starting_date" "$backups_to_keep"
    return 1
  fi

  # Remove the backup directory
  printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Removing backup directory: $backup_dir")"
  if ! rm -rf "$backup_dir"; then
    __epx_backup__log_status_to_file "Backup failed, failed to remove backup directory" "$backup_info" "$input_path" "$output_path" "$backup_file" "$starting_date" "$backups_to_keep"
    return 1
  fi

  # Remove old backups
  printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Removing old backups...")"
  mapfile -t backups < <(find "$output_path" -maxdepth 1 -name "*.tar.zst" -printf "%f\n" | sort -r | tail -n +$((backups_to_keep + 1)))

  for backup in "${backups[@]}"; do
    printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Removing backup: $output_path/$backup")"
    if ! rm -f "$output_path/$backup"; then
      __epx_backup__log_status_to_file "Backup failed, failed to remove old backups" "$backup_info" "$input_path" "$output_path" "$backup_file" "$starting_date" "$backups_to_keep"
      return 1
    fi
  done

  # Log the status to a file
  printf "%s\n" "[$(_c LIGHT_BLUE "Backup")] $(_c LIGHT_YELLOW "Logging status to file...")"
  __epx_backup__log_status_to_file "Backup created successfully" "$backup_info" "$input_path" "$output_path" "$backup_file" "$starting_date" "$backups_to_keep"
}
