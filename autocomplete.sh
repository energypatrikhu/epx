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

# Detect current shell
_EPX_SHELL=$(_epx_detect_shell)

if [ "$_EPX_SHELL" = "bash" ]; then
  _epx_completions() {
    _autocomplete "self-update mk-cert update-bees backup"
  }
  complete -F _epx_completions epx
elif [ "$_EPX_SHELL" = "fish" ]; then
  complete -c epx -a 'self-update mk-cert update-bees backup'
fi
