if [[ -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  source "${EPX_HOME}/commands/game-servers/minecraft/_helpers.sh"

  __epx-mc-list-containers() {
    local containers
    containers="$(docker ps -a --format '{{.Names}}' | grep '^mc-' | grep '-server$' | sed 's/^mc-//;s/-server$//')"
    _autocomplete "${containers}"
  }
  complete -F __epx-mc-list-containers mc.restart
  complete -F __epx-mc-list-containers mc.start
  complete -F __epx-mc-list-containers mc.stop
  complete -F __epx-mc-list-containers mc.rm

  __epx-mc-list-servers() {
    local servers
    servers="$(__epx-mc-get-servers "${1-}")"
    _autocomplete "${servers}"
  }
  complete -F __epx-mc-list-servers mc.up

  __epx-mc-list-server-templates() {
    local templates
    templates="$(__epx-mc-get-server-templates "${1-}")"
    _autocomplete "${templates}"
  }
  complete -F __epx-mc-list-server-templates mc.add
fi
