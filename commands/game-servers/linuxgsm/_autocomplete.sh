_gsm_autocomplete() {
  local containers
  containers="$(docker ps -a --format '{{.Names}}' | grep '^linuxgsm-' | sed 's/^linuxgsm-//')"
  _autocomplete "${containers}"
}
complete -F _gsm_autocomplete gsm
complete -F _gsm_autocomplete gsm.start
complete -F _gsm_autocomplete gsm.stop
complete -F _gsm_autocomplete gsm.rm

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
  complete -F _d_autocomplete_compose gsm.up
fi
