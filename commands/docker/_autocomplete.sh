source "${EPX_HOME}/helpers/check-compose-file.sh"

__epx_bash_d_containers() {
  local containers
  containers="$(docker ps -a --format '{{.Names}}')"
  _autocomplete "${containers}"
}
complete -F __epx_bash_d_containers d.attach
complete -F __epx_bash_d_containers d.exec
complete -F __epx_bash_d_containers d.inspect
complete -F __epx_bash_d_containers d.i
complete -F __epx_bash_d_containers d.logs
complete -F __epx_bash_d_containers d.log
complete -F __epx_bash_d_containers d.shell
complete -F __epx_bash_d_containers d.sh
complete -F __epx_bash_d_containers d.updates

__epx_bash_d_containers_with_all() {
  local containers
  containers="$(docker ps -a --format '{{.Names}}')"
  _autocomplete "all ${containers}"
}
complete -F __epx_bash_d_containers_with_all d.remove
complete -F __epx_bash_d_containers_with_all d.rm
complete -F __epx_bash_d_containers_with_all d.restart
complete -F __epx_bash_d_containers_with_all d.start
complete -F __epx_bash_d_containers_with_all d.stop
complete -F __epx_bash_d_containers_with_all d.stats
complete -F __epx_bash_d_containers_with_all d.stat

__epx_bash_d_containers_list() {
  _autocomplete "created restarting running removing paused exited dead"
}
complete -F __epx_bash_d_containers_list d.list
complete -F __epx_bash_d_containers_list d.ls

__epx_bash_d_containers_prune() {
  _autocomplete "all images containers volumes networks build"
}
complete -F __epx_bash_d_containers_prune d.prune

__epx_bash_d_container_templates() {
  local available_templates
  available_templates="$(find "${EPX_HOME}"/.templates/docker/dockerfile -maxdepth 1 -type f -name '*.template' -exec basename {} .template \; | tr '\n' ' ')"
  _autocomplete "${available_templates}"
}
complete -F __epx_bash_d_container_templates d.make
complete -F __epx_bash_d_container_templates d.mk

__epx_bash_d_container_directories() {
  . "${EPX_HOME}/.config/docker.config"

  local container_dirs=()
  local d
  for d in "${CONTAINERS_DIR}"/*; do
    if [[ -d "${d}" ]]; then
      if check_compose_file "${d}"; then
        container_dirs+=("$(basename -- "${d}")")
      fi
    fi
  done

  _autocomplete "${container_dirs[@]}"
}
if [[ -f "${EPX_HOME}/.config/docker.config" ]]; then
  complete -F __epx_bash_d_container_directories d.up
  complete -F __epx_bash_d_container_directories d.pull
fi

if [ -f "/usr/share/bash-completion/completions/docker" ]; then
  source /usr/share/bash-completion/completions/docker
  complete -F __start_docker d

  __epx_bash_dc_completions() {
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
  complete -F __epx_bash_dc_completions dc

  __epx_bash_d_net_completions() {
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
  complete -F __epx_bash_d_net_completions d.net
  complete -F __epx_bash_d_net_completions d.network
fi
