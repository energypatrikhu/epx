#!/usr/bin/env bash

_load_aliases() {
  local element
  for element in "${1-}"/*; do
    if [[ -d "${element}" ]]; then
      _load_aliases "${element}"
      continue
    fi

    if [[ -f "${element}" ]] && [[ "${element}" == *.sh ]]; then
      if [[ "${element}" == *"_alias.sh" ]]; then
        echo "Loading alias from ${element}"
        source "${element}"
      fi
    fi
  done
}
_load_aliases "${EPX_HOME}/commands"
