#!/bin/bash

_autocomplete() {
  local cur opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  opts=$*

  COMPREPLY=("$(compgen -W "${opts}" -- "$cur")")
}
