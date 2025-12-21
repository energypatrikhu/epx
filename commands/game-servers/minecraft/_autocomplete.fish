# Fish completions for Minecraft commands

if test -f "$EPX_HOME/.config/minecraft.config"
  function __epx_fish_mc_containers
    docker ps -a --format '{{.Names}}' | grep '^mc-' | grep '-server$' | sed 's/^mc-//;s/-server$//'
  end

  complete -c mc.restart -a '(__epx_fish_mc_containers)'
  complete -c mc.stop -a '(__epx_fish_mc_containers)'
  complete -c mc.shell -a '(__epx_fish_mc_containers)'
  complete -c mc.attach -a '(__epx_fish_mc_containers)'
  complete -c mc.log -a '(__epx_fish_mc_containers)'
  complete -c mc.rm -a '(__epx_fish_mc_containers)'

  function __epx_fish_mc_servers
    set -l config_file "$EPX_HOME/.config/minecraft.config"
    set -l minecraft_dir (grep '^MINECRAFT_DIR=' $config_file | cut -d'=' -f2 | tr -d '"' | tr -d "'")

    if test -d "$minecraft_dir/servers"
      for d in $minecraft_dir/servers/*
        if test -d "$d"
          basename "$d"
        end
      end
    end
  end

  complete -c mc.start -a '(__epx_fish_mc_servers)'

  function __epx_fish_mc_templates
    set -l config_file "$EPX_HOME/.config/minecraft.config"
    set -l minecraft_dir (grep '^MINECRAFT_DIR=' $config_file | cut -d'=' -f2 | tr -d '"' | tr -d "'")

    if test -d "$minecraft_dir/internals/templates/platforms"
      for f in $minecraft_dir/internals/templates/platforms/*
        if test -f "$f"
          basename "$f"
        end
      end
    end
  end

  complete -c mc.add -a '(__epx_fish_mc_templates)'
end
