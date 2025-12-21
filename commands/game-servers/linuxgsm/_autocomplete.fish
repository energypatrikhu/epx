# Fish completions for LinuxGSM commands

function __epx_fish_gsm_containers
  docker ps -a --format '{{.Names}}' | grep '^linuxgsm-' | sed 's/^linuxgsm-//'
end

complete -c gsm -a '(__epx_fish_gsm_containers)'
complete -c gsm.start -a '(__epx_fish_gsm_containers)'
complete -c gsm.stop -a '(__epx_fish_gsm_containers)'
complete -c gsm.rm -a '(__epx_fish_gsm_containers)'

function __epx_fish_gsm_serverlist
  curl -sL https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/refs/heads/master/lgsm/data/serverlist.csv | cut -d, -f1 | tail -n +2
end

complete -c gsm.add -a '(__epx_fish_gsm_serverlist)'

if test -f "$EPX_HOME/.config/docker.config"
  function __epx_fish_gsm_compose_directories
    set -l config_file "$EPX_HOME/.config/docker.config"
    set -l containers_dir (grep '^CONTAINERS_DIR=' $config_file | cut -d'=' -f2 | tr -d '"' | tr -d "'")

    for d in $containers_dir/*
      if test -d "$d" -a -f "$d/docker-compose.yml"
        set -l dirname (basename "$d")
        if string match -q 'linuxgsm-*' $dirname
          string replace 'linuxgsm-' '' $dirname
        end
      end
    end
  end

  complete -c gsm.up -a '(__epx_fish_gsm_compose_directories)'
end
