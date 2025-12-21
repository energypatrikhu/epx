# Bash completions for Minecraft commands
if [[ -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  source "${EPX_HOME}/commands/game-servers/minecraft/_helpers.sh"

  __epx_bash_mc_containers() {
    local containers
    containers="$(docker ps -a --format '{{.Names}}' | grep '^mc-' | grep '-server$' | sed 's/^mc-//;s/-server$//')"
    _autocomplete "${containers}"
  }
  complete -F __epx_bash_mc_containers mc.restart
  complete -F __epx_bash_mc_containers mc.stop
  complete -F __epx_bash_mc_containers mc.shell
  complete -F __epx_bash_mc_containers mc.attach
  complete -F __epx_bash_mc_containers mc.log
  complete -F __epx_bash_mc_containers mc.rm

  __epx_bash_mc_servers() {
    local servers
    servers="$(__epx-mc-get-servers "${1-}")"
    _autocomplete "${servers}"
  }
  complete -F __epx_bash_mc_servers mc.start

  __epx_bash_mc_templates() {
    if [[ ${COMP_CWORD} -eq 1 ]]; then
      local templates
      templates="$(__epx-mc-get-server-templates "${1-}")"
      _autocomplete "${templates}"
    fi
  }
  complete -F __epx_bash_mc_templates mc.add
fi
