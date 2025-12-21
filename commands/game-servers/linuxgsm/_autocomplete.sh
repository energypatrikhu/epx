# Detect current shell
_EPX_SHELL=$(_epx_detect_shell)

if [ "$_EPX_SHELL" = "bash" ]; then
  # Bash completions
  _gsm_autocomplete() {
    local containers
    containers="$(docker ps -a --format '{{.Names}}' | grep '^linuxgsm-' | sed 's/^linuxgsm-//')"
    _autocomplete "${containers}"
  }
  complete -F _gsm_autocomplete gsm
  complete -F _gsm_autocomplete gsm.start
  complete -F _gsm_autocomplete gsm.stop
  complete -F _gsm_autocomplete gsm.rm

  _gsm_autocomplete_add() {
    # https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/refs/heads/master/lgsm/data/serverlist.csv
    local servers
    servers="$(curl -sL https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/refs/heads/master/lgsm/data/serverlist.csv | cut -d, -f1 | tail -n +2)"
    _autocomplete "${servers}"
  }
  complete -F _gsm_autocomplete_add gsm.add

  _gsm_autocomplete_compose() {
    . "${EPX_HOME}/.config/docker.config"

    local container_dirs=()
    local d
    for d in "${CONTAINERS_DIR}"/*; do
      if [[ -d "${d}" ]]; then
        if [[ -f "${d}/docker-compose.yml" ]]; then
          local dirname="$(basename -- "${d}")"
          if [[ "${dirname}" == linuxgsm-* ]]; then
            container_dirs+=("${dirname#linuxgsm-}")
          fi
        fi
      fi
    done

    _autocomplete "${container_dirs[@]}"
  }
  if [[ -f "${EPX_HOME}/.config/docker.config" ]]; then
    complete -F _gsm_autocomplete_compose gsm.up
  fi

elif [ "$_EPX_SHELL" = "fish" ]; then
  # Fish completions
  function __epx_gsm_containers
    docker ps -a --format '{{.Names}}' | grep '^linuxgsm-' | sed 's/^linuxgsm-//'
  end

  complete -c gsm -a '(__epx_gsm_containers)'
  complete -c gsm.start -a '(__epx_gsm_containers)'
  complete -c gsm.stop -a '(__epx_gsm_containers)'
  complete -c gsm.rm -a '(__epx_gsm_containers)'

  function __epx_gsm_serverlist
    curl -sL https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/refs/heads/master/lgsm/data/serverlist.csv | cut -d, -f1 | tail -n +2
  end

  complete -c gsm.add -a '(__epx_gsm_serverlist)'

  if test -f "$EPX_HOME/.config/docker.config"
    function __epx_gsm_compose_dirs
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

    complete -c gsm.up -a '(__epx_gsm_compose_dirs)'
  end
fi
