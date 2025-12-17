if [[ -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  . "${EPX_HOME}/.config/minecraft.config"

  __epx-mc-get-servers() {
    local servers
    if [[ -d "${MINECRAFT_DIR}/servers" ]] && [[ -n "$(/bin/ls -A "${MINECRAFT_DIR}/servers" 2>/dev/null)" ]]; then
      servers=$(find "${MINECRAFT_DIR}/servers" -type d -maxdepth 1 -mindepth 1 -printf '%f\n')
    fi
    echo "${servers}"
  }

  __epx-mc-get-server-templates() {
    local templates
    templates=$(find "${MINECRAFT_DIR}/internals/templates/platforms" -type f -maxdepth 1 -mindepth 1 -printf '%f\n')
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
fi
