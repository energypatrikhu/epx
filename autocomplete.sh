#!/bin/bash

. "${EPX_HOME}/helpers/autocomplete.sh"

_load_autocomplete() {
  local element
  for element in "${1-}"/*; do
    if [[ -d "${element}" ]]; then
      _load_autocomplete "${element}"
      continue
    fi

    if [[ -f "${element}" ]] && [[ "${element}" == *.sh ]]; then
      if [[ "${element}" == *"_autocomplete.sh" ]]; then
        # echo "Loading autocomplete from ${element}"
        source "${element}"
      fi
    fi
  done
}
_load_autocomplete "${EPX_HOME}/commands"

_epx_completions() {
  _autocomplete "self-update mk-cert update-bees backup"
}
complete -F _epx_completions epx

if [ -f "/usr/share/bash-completion/completions/docker" ]; then
  source /usr/share/bash-completion/completions/docker
  complete -F __start_docker d
fi

if [ -f "/usr/share/bash-completion/completions/docker" ]; then
  source /usr/share/bash-completion/completions/docker
  __docker_compose_subcommand() {
    COMP_WORDS=(docker compose "${COMP_WORDS[@]:1}")
    ((COMP_CWORD++))
    __docker_complete_subcommand
  }
  complete -F __docker_compose_subcommand dc
fi
