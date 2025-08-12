if [[ -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  . "${EPX_HOME}/.config/minecraft.config"

  __epx-mc-get-configs() {
    local configs
    configs=$(find "${MINECRAFT_PROJECT_DIR}/configs" -type f -name "*.env" -not \( -name "@*" \) -printf '%f\n' | sed 's/\.env$//')
    echo "${configs}"
  }
  __epx-mc-get-configs-examples() {
    local examples
    examples=$(find "${MINECRAFT_PROJECT_DIR}/configs/examples" -type f -name "@*.env" -printf '%f\n' | sed 's/^@example.//' | sed 's/\.env$//')
    echo "${examples}"
  }
fi
