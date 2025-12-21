# Detect current shell
_EPX_SHELL=$(_epx_detect_shell)

if [ "$_EPX_SHELL" = "bash" ]; then
  # Bash completions
  _d_autocomplete() {
    local containers
    containers="$(docker ps -a --format '{{.Names}}')"
    _autocomplete "${containers}"
  }
  complete -F _d_autocomplete d.attach
  complete -F _d_autocomplete d.exec
  complete -F _d_autocomplete d.inspect
  complete -F _d_autocomplete d.i
  complete -F _d_autocomplete d.logs
  complete -F _d_autocomplete d.log
  complete -F _d_autocomplete d.shell

  _d_autocomplete_all() {
    local containers
    containers="$(docker ps -a --format '{{.Names}}')"
    _autocomplete "all ${containers}"
  }
  complete -F _d_autocomplete_all d.remove
  complete -F _d_autocomplete_all d.rm
  complete -F _d_autocomplete_all d.restart
  complete -F _d_autocomplete_all d.start
  complete -F _d_autocomplete_all d.stop
  complete -F _d_autocomplete_all d.stats
  complete -F _d_autocomplete_all d.stat

  _d_autocomplete_list() {
    _autocomplete "created restarting running removing paused exited dead"
  }
  complete -F _d_autocomplete_list d.list
  complete -F _d_autocomplete_list d.ls

  _d_autocomplete_prune() {
    _autocomplete "all images containers volumes networks build"
  }
  complete -F _d_autocomplete_prune d.prune

  _d_autocomplete_templates() {
    local available_templates
    available_templates="$(find "${EPX_HOME}"/.templates/docker/dockerfile -maxdepth 1 -type f -name '*.template' -exec basename {} .template \; | tr '\n' ' ')"
    _autocomplete "${available_templates}"
  }
  complete -F _d_autocomplete_templates d.make
  complete -F _d_autocomplete_templates d.mk

  _d_autocomplete_compose() {
    . "${EPX_HOME}/.config/docker.config"

    local container_dirs=()
    local d
    for d in "${CONTAINERS_DIR}"/*; do
      if [[ -d "${d}" ]]; then
        if [[ -f "${d}/docker-compose.yml" ]]; then
          container_dirs+=("$(basename -- "${d}")")
        fi
      fi
    done

    _autocomplete "${container_dirs[@]}"
  }
  if [[ -f "${EPX_HOME}/.config/docker.config" ]]; then
    complete -F _d_autocomplete_compose d.up
    complete -F _d_autocomplete_compose d.pull
  fi

  if [ -f "/usr/share/bash-completion/completions/docker" ]; then
    source /usr/share/bash-completion/completions/docker
    complete -F __start_docker d

    _dc_completions() {
      local i
      local -a new_words=("docker" "compose")
      for ((i=1; i<${#COMP_WORDS[@]}; i++)); do
        new_words+=("${COMP_WORDS[i]}")
      done
      COMP_WORDS=("${new_words[@]}")
      COMP_CWORD=$((COMP_CWORD + 1))
      COMP_LINE="${COMP_LINE/dc/docker compose}"
      COMP_POINT=$((COMP_POINT + 14))

      __start_docker
    }
    complete -F _dc_completions dc

    _d.net_completions() {
      local i
      local -a new_words=("docker" "network")
      for ((i=1; i<${#COMP_WORDS[@]}; i++)); do
        new_words+=("${COMP_WORDS[i]}")
      done
      COMP_WORDS=("${new_words[@]}")
      COMP_CWORD=$((COMP_CWORD + 1))

      # Handle both d.net and d.network
      if [[ "$COMP_LINE" == *"d.network"* ]]; then
        COMP_LINE="${COMP_LINE/d.network/docker network}"
        COMP_POINT=$((COMP_POINT + 5))
      else
        COMP_LINE="${COMP_LINE/d.net/docker network}"
        COMP_POINT=$((COMP_POINT + 9))
      fi

      __start_docker
    }
    complete -F _d.net_completions d.net
    complete -F _d.net_completions d.network
  fi

elif [ "$_EPX_SHELL" = "fish" ]; then
  # Fish completions
  function __epx_docker_containers
    docker ps -a --format '{{.Names}}'
  end

  complete -c d.attach -a '(__epx_docker_containers)'
  complete -c d.exec -a '(__epx_docker_containers)'
  complete -c d.inspect -a '(__epx_docker_containers)'
  complete -c d.i -a '(__epx_docker_containers)'
  complete -c d.logs -a '(__epx_docker_containers)'
  complete -c d.log -a '(__epx_docker_containers)'
  complete -c d.shell -a '(__epx_docker_containers)'

  function __epx_docker_containers_with_all
    echo "all"
    docker ps -a --format '{{.Names}}'
  end

  complete -c d.remove -a '(__epx_docker_containers_with_all)'
  complete -c d.rm -a '(__epx_docker_containers_with_all)'
  complete -c d.restart -a '(__epx_docker_containers_with_all)'
  complete -c d.start -a '(__epx_docker_containers_with_all)'
  complete -c d.stop -a '(__epx_docker_containers_with_all)'
  complete -c d.stats -a '(__epx_docker_containers_with_all)'
  complete -c d.stat -a '(__epx_docker_containers_with_all)'

  complete -c d.list -a 'created restarting running removing paused exited dead'
  complete -c d.ls -a 'created restarting running removing paused exited dead'

  complete -c d.prune -a 'all images containers volumes networks build'

  function __epx_docker_templates
    find "$EPX_HOME"/.templates/docker/dockerfile -maxdepth 1 -type f -name '*.template' -exec basename {} .template \;
  end

  complete -c d.make -a '(__epx_docker_templates)'
  complete -c d.mk -a '(__epx_docker_templates)'

  if test -f "$EPX_HOME/.config/docker.config"
    function __epx_docker_compose_dirs
      set -l config_file "$EPX_HOME/.config/docker.config"
      set -l containers_dir (grep '^CONTAINERS_DIR=' $config_file | cut -d'=' -f2 | tr -d '"' | tr -d "'")

      for d in $containers_dir/*
        if test -d "$d" -a -f "$d/docker-compose.yml"
          basename "$d"
        end
      end
    end

    complete -c d.up -a '(__epx_docker_compose_dirs)'
    complete -c d.pull -a '(__epx_docker_compose_dirs)'
  end
fi
