# Bash completions for LinuxGSM commands
__epx_bash_gsm_containers() {
  local containers
  containers="$(docker ps -a --format '{{.Names}}' | grep '^linuxgsm-' | sed 's/^linuxgsm-//')"
  _autocomplete "${containers}"
}
complete -F __epx_bash_gsm_containers gsm
complete -F __epx_bash_gsm_containers gsm.restart
complete -F __epx_bash_gsm_containers gsm.start
complete -F __epx_bash_gsm_containers gsm.stop
complete -F __epx_bash_gsm_containers gsm.rm

__epx_bash_gsm_serverlist() {
  # https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/refs/heads/master/lgsm/data/serverlist.csv
  local servers
  servers="$(curl -sL https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/refs/heads/master/lgsm/data/serverlist.csv | cut -d, -f1 | tail -n +2)"
  _autocomplete "${servers}"
}
complete -F __epx_bash_gsm_serverlist gsm.add

if [[ -f "${EPX_HOME}/.config/docker.config" ]]; then
  __epx_bash_gsm_compose_directories() {
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

  complete -F __epx_bash_gsm_compose_directories gsm.up
fi
