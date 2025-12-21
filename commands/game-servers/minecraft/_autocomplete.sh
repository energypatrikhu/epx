# Detect current shell
_EPX_SHELL=$(_epx_detect_shell)

if [ "$_EPX_SHELL" = "bash" ]; then
  # Bash completions
  if [[ -f "${EPX_HOME}/.config/minecraft.config" ]]; then
    source "${EPX_HOME}/commands/game-servers/minecraft/_helpers.sh"

    __epx-mc-list-containers() {
      local containers
      containers="$(docker ps -a --format '{{.Names}}' | grep '^mc-' | grep '-server$' | sed 's/^mc-//;s/-server$//')"
      _autocomplete "${containers}"
    }
    complete -F __epx-mc-list-containers mc.restart
    complete -F __epx-mc-list-containers mc.stop
    complete -F __epx-mc-list-containers mc.shell
    complete -F __epx-mc-list-containers mc.attach
    complete -F __epx-mc-list-containers mc.log
    complete -F __epx-mc-list-containers mc.rm

    __epx-mc-list-servers() {
      local servers
      servers="$(__epx-mc-get-servers "${1-}")"
      _autocomplete "${servers}"
    }
    complete -F __epx-mc-list-servers mc.start

    __epx-mc-list-server-templates() {
      if [[ ${COMP_CWORD} -eq 1 ]]; then
        local templates
        templates="$(__epx-mc-get-server-templates "${1-}")"
        _autocomplete "${templates}"
      fi
    }
    complete -F __epx-mc-list-server-templates mc.add
  fi

elif [ "$_EPX_SHELL" = "fish" ]; then
  # Fish completions
  if test -f "$EPX_HOME/.config/minecraft.config"
    function __epx_mc_containers
      docker ps -a --format '{{.Names}}' | grep '^mc-' | grep '-server$' | sed 's/^mc-//;s/-server$//'
    end

    complete -c mc.restart -a '(__epx_mc_containers)'
    complete -c mc.stop -a '(__epx_mc_containers)'
    complete -c mc.shell -a '(__epx_mc_containers)'
    complete -c mc.attach -a '(__epx_mc_containers)'
    complete -c mc.log -a '(__epx_mc_containers)'
    complete -c mc.rm -a '(__epx_mc_containers)'

    function __epx_mc_servers
      set -l config_file "$EPX_HOME/.config/minecraft.config"
      set -l servers_dir (grep '^SERVERS_DIR=' $config_file | cut -d'=' -f2 | tr -d '"' | tr -d "'")

      for d in $servers_dir/*
        if test -d "$d"
          basename "$d"
        end
      end
    end

    complete -c mc.start -a '(__epx_mc_servers)'

    function __epx_mc_templates
      set -l config_file "$EPX_HOME/.config/minecraft.config"
      set -l templates_dir (grep '^SERVER_TEMPLATES=' $config_file | cut -d'=' -f2 | tr -d '"' | tr -d "'")

      for d in $templates_dir/*
        if test -d "$d"
          basename "$d"
        end
      end
    end

    complete -c mc.add -a '(__epx_mc_templates)'
  end
fi
