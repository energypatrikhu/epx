if [[ -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  source "${EPX_HOME}/commands/game-servers/minecraft/_helpers.sh"

  __epx-mc-list-configs() {
    local configs
    configs="$(__epx-mc-get-configs "${1}")"
    _autocomplete "${configs}"
  }
  complete -F __epx-mc-list-configs mc

  __epx-mc-list-configs-examples() {
    local examples
    examples="$(__epx-mc-get-configs-examples "${1}")"
    _autocomplete "${examples}"
  }
  complete -F __epx-mc-list-configs-examples mc.create
fi
