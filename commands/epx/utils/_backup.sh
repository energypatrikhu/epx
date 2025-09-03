__epx_backup__get_distro() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "${ID}"
  else
    echo "unknown"
  fi
}

__epx_backup__get_beesd_installed() {
  if command -v beesd &>/dev/null; then
    return 0
  else
    return 1
  fi
}

__epx_backup__stop_beesd() {
  if __epx_backup__get_beesd_installed; then
    echo -e "[$(_c LIGHT_BLUE "EPX - Backup")] $(_c LIGHT_YELLOW "Stopping all beesd processes...")"
    sudo systemctl stop beesd@*
  fi
}

__epx_backup__start_beesd() {
  if __epx_backup__get_beesd_installed; then
    echo -e "[$(_c LIGHT_BLUE "EPX - Backup")] $(_c LIGHT_YELLOW "Starting all beesd processes...")"
    sudo systemctl start beesd@* --all
  fi
}

__epx_backup__check_and_install_utils() {
  local required_utils=("rsync" "zstd" "tar")

  for util in "${required_utils[@]}"; do
    if ! command -v "${util}" &>/dev/null; then
      echo -e "[$(_c LIGHT_BLUE "EPX - Backup")] $(_c LIGHT_RED "Error: ${util} is not installed. Installing ${util}...")"

      local distro=$(__epx_backup__get_distro)
      case "${distro}" in
      debian | ubuntu)
        sudo apt-get update && sudo apt-get install -y "${util}"
        ;;
      fedora | centos | rhel)
        sudo dnf install -y "${util}" || sudo yum install -y "${util}"
        ;;
      arch)
        sudo pacman -Syu --noconfirm "${util}"
        ;;
      *)
        echo -e "[$(_c LIGHT_BLUE "EPX - Backup")] $(_c LIGHT_RED "Error: Unsupported distribution. Please install ${util} manually.")"
        return 1
        ;;
      esac
    fi
  done
}

__epx_backup__log_status_to_file() {
  local status="${1-}"
  local logfile="${2-}"
  local input_path="${3-}"
  local output_path="${4-}"
  local output_zst_file="${5-}"
  local starting_date="${6-}"
  local backups_to_keep="${7-}"

  local current_date=$(date -d "${starting_date}" "+%Y. %m. %d %H:%M:%S")
  local backup_size="N/A"
  local num_of_backups=$(find "${output_path}" -maxdepth 1 -name "*.tar.zst" -printf "%f\n" | wc -l)

  if [[ -f "${output_zst_file}" ]]; then
    backup_size=$(du -h "${output_zst_file}" | awk '{print $2}')
  fi

  # Get the size of the backup directory, exclude log file
  local total_size=$(du -h --exclude="backup-info.log" "${output_path}" | awk '{print $2}')

  echo "${status} (${input_path}) (${backup_size}) (${total_size}) (${num_of_backups}/${backups_to_keep}) (${current_date})" >"${logfile}"

  # Start all beesd processes after creating a backup
  __epx_backup__start_beesd
}

__epx_backup__compress() {
  local input_dir="${1-}"
  local backup_file="${2-}"
  local excluded_array="${3-}"

  # Compress the backup directory with tar and zstd
  # Build --exclude options from excluded_array
  local exclude_args=()
  for exclude in "${excluded_array[@]}"; do
    exclude_args+=(--exclude="${exclude}")
  done

  if ! tar "${exclude_args[@]}" -I "zstd -T0 -19 --long" -cvf "${backup_file}" -C "${input_dir}" .; then
    return 1
  fi
}

__epx_backup() {
  local input_path="${1-}"
  local output_path="${2-}"
  local backups_to_keep="${3-}"
  local excluded=""${4-}""

  # Stop the script if any of the required arguments are missing
  if [[ -z "${input_path}" || -z "${output_path}" || -z "${backups_to_keep}" ]]; then
    echo -e "[$(_c LIGHT_BLUE "EPX - Backup")] $(_c LIGHT_YELLOW "Usage: backup <input path> <output path> <backups to keep> [excluded directories, files separated with (,)]")"
    return 1
  fi

  # Check if the required utilities are installed, if not, install them
  if ! __epx_backup__check_and_install_utils; then
    echo -e "[$(_c LIGHT_BLUE "EPX - Backup")] $(_c LIGHT_RED "Error: Failed to install required utilities.")"
    return 1
  fi

  # Save the starting date and current timestamp
  local starting_date=$(date +"%Y-%m-%d %H:%M:%S")
  local current_timestamp=$(date -d "${starting_date}" "+%Y-%m-%d_%H-%M-%S")

  # Set backup info variables
  local backup_info="${output_path}/backup-info.log"
  # local backup_dir="${output_path}/${current_timestamp}"
  local backup_file="${output_path}/${current_timestamp}.tar.zst"

  # Create an array of excluded directories and files
  mapfile -t excluded_array < <(echo "${excluded}" | tr "," "\n")

  echo -e "[$(_c LIGHT_BLUE "EPX - Backup")] $(_c LIGHT_YELLOW "Starting backup...")"

  # Stop all beesd processes before creating a backup
  __epx_backup__stop_beesd

  # Check if the input path exists and is a directory
  if [[ ! -d "${input_path}" ]]; then
    echo -e "[$(_c LIGHT_BLUE "EPX - Backup")] $(_c LIGHT_RED "Error: Input path does not exist or is not a directory: ${input_path}")"
    return 1
  fi

  # Check if the output path exists, if not, create it
  if [[ ! -d "${output_path}" ]]; then
    echo -e "[$(_c LIGHT_BLUE "EPX - Backup")] $(_c LIGHT_YELLOW "Creating output directory: ${output_path}")"
    if ! mkdir -p "${output_path}"; then
      echo -e "[$(_c LIGHT_BLUE "EPX - Backup")] $(_c LIGHT_RED "Error: Failed to create output directory: ${output_path}")"
      return 1
    fi
  fi

  # Compress the input path into a tar.zst file
  echo -e "[$(_c LIGHT_BLUE "EPX - Backup")] $(_c LIGHT_YELLOW "Compressing files...")"
  if ! __epx_backup__compress "${input_path}" "${backup_file}" "${excluded_array[@]}"; then
    __epx_backup__log_status_to_file "Backup failed, failed to compress files" "${backup_info}" "${input_path}" "${output_path}" "${backup_file}" "${starting_date}" "${backups_to_keep}"
    return 1
  fi

  # Remove old backups
  echo -e "[$(_c LIGHT_BLUE "EPX - Backup")] $(_c LIGHT_YELLOW "Removing old backups...")"
  mapfile -t backups < <(find "${output_path}" -maxdepth 1 -name "*.tar.zst" -printf "%f\n" | sort -r | tail -n +$((backups_to_keep + 1)))

  for backup in "${backups[@]}"; do
    echo -e "[$(_c LIGHT_BLUE "EPX - Backup")] $(_c LIGHT_YELLOW "Removing backup: ${output_path}/${backup}")"
    if ! rm -f "${output_path}/${backup}"; then
      __epx_backup__log_status_to_file "Backup failed, failed to remove old backups" "${backup_info}" "${input_path}" "${output_path}" "${backup_file}" "${starting_date}" "${backups_to_keep}"
      return 1
    fi
  done

  # Log the status to a file
  echo -e "[$(_c LIGHT_BLUE "EPX - Backup")] $(_c LIGHT_YELLOW "Logging status to file...")"
  __epx_backup__log_status_to_file "Backup created successfully" "${backup_info}" "${input_path}" "${output_path}" "${backup_file}" "${starting_date}" "${backups_to_keep}"
}
