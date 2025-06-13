#!/bin/bash

d.make() {
  if [[ -z $1 ]]; then
    __epx_echo "[$(_c LIGHT_BLUE "Docker - Make")] $(_c LIGHT_YELLOW "Usage: d.mk <interpreter>")"
    return
  fi

  local interpreter="$1"

  if [[ ! -f "$EPX_PATH/.templates/docker/dockerfile/$interpreter.template" ]]; then
    __epx_echo "[$(_c LIGHT_RED "Docker - Make")] $(_c LIGHT_YELLOW "Template for interpreter '$interpreter' not found.")"
    return
  fi

  if [[ -f Dockerfile ]]; then
    __epx_echo "[$(_c LIGHT_RED "Docker - Make")] $(_c LIGHT_YELLOW "Dockerfile already exists. Please remove it before creating a new one.")"
    return
  fi

  if ! cp -f "$EPX_PATH/.templates/docker/dockerfile/$interpreter.template" Dockerfile >/dev/null 2>&1; then
    __epx_echo "[$(_c LIGHT_RED "Docker - Make")] $(_c LIGHT_YELLOW "Failed to copy template for interpreter '$interpreter'.")"
    return
  fi

  __epx_echo "[$(_c LIGHT_BLUE "Docker - Make")] $(_c LIGHT_GREEN "Dockerfile created from template for interpreter '$interpreter'.")"
}
d.mk() {
  d.make $@
}

. "$EPX_PATH/commands/docker/_autocomplete.sh"
complete -F _d_autocomplete_templates d.make
complete -F _d_autocomplete_templates d.mk
