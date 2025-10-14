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
