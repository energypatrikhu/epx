if [[ -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  . "${EPX_HOME}/.config/minecraft.config"

  __epx-mc-get-configs() {
    find "${MINECRAFT_PROJECT_DIR}/configs" -type f -name "*.env" -not \( -name "@*" \) -printf '%f\n' | sed 's/\.env$//'
  }
  __epx-mc-get-configs-examples() {
    find "${MINECRAFT_PROJECT_DIR}/configs/examples" -type f -name "@*.env" -printf '%f\n' | sed 's/^@example.//' | sed 's/\.env$//'
  }
fi
