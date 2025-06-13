#!/bin/bash

d.make() {
  if [[ -z $1 ]]; then
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Make")] $(_c LIGHT_YELLOW "Usage: d.mk <interpreter>")"
    return
  fi

  local interpreter="$1"

  if [[ ! -f "$EPX_PATH/.templates/dockerfile/$interpreter.template" ]]; then
    __epx_echo "[$(_c LIGHT_RED "Docker - Make")] $(_c LIGHT_YELLOW "Template for interpreter '$interpreter' not found.")"
    return
  fi

  cp -f "$EPX_PATH/.templates/dockerfile/$interpreter.template" Dockerfile
}
d.mk() {
  d.make $@
}

. "$EPX_PATH/commands/docker/_autocomplete.sh"
complete -F _d_autocomplete_templates d.make
complete -F _d_autocomplete_templates d.mk
