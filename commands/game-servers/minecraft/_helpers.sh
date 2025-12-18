if [[ -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  . "${EPX_HOME}/.config/minecraft.config"

  __epx-mc-get-containers() {
    local servers
    servers=$(docker ps -a --format '{{.Names}}' | grep '^mc-' | grep '-server$' | sed 's/^mc-//;s/-server$//')
    echo "${servers}"
  }

  __epx-mc-get-servers() {
    local servers
    servers=$(find "${MINECRAFT_DIR}/servers" -maxdepth 1 -mindepth 1 -type d -printf '%f\n')
    echo "${servers}"
  }

  __epx-mc-get-server-templates() {
    local templates
    templates=$(find "${MINECRAFT_DIR}/internals/templates/platforms" -maxdepth 1 -mindepth 1 -type f -printf '%f\n')
    echo "${templates}"
  }

  __epx-mc-get-env-value() {
    local config_env="${1-}"
    local var_name="${2-}"
    grep -iE "^${var_name}\s*=" "${config_env}" | sed -E "s/^${var_name}\s*=\s*//I; s/[[:space:]]*$//"
  }

  __epx-mc-get-backup-enabled() {
    local config_env="${1-}"
    local backup_enabled=$(__epx-mc-get-env-value "${config_env}" "BACKUP")
    if [[ "${backup_enabled,,}" == "true" ]]; then
      echo "true"
    else
      echo "false"
    fi
  }

  _epx-mc-get-platform-type() {
    local server_dir="${1-}"
    local platform_type
    platform_type=$(basename -- "${server_dir}")
    platform_type=${platform_type%%_*}
    echo "${platform_type}"
  }
fi
