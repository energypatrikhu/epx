#!/bin/bash

# Description: Main script for the EPX CLI
# Author: EnergyPatrikHU

# Load helpers
for file in $EPX_HOME/helpers/*.sh; do
  . "$file"
done

# Load aliases
. $EPX_HOME/aliases.sh

# Load custom commands
for dir in "$EPX_HOME"/commands/*; do
  if [ -d "$dir" ]; then
    for file in "$dir"/*.sh; do
      # skip file if start with an underscore
      [[ $(basename "$file") =~ ^_ ]] && continue

      . "$file"
    done
  fi
done

# Load all utils
UTILS=()
for file in "$EPX_HOME"/utils/*.sh; do
  . "$file"
  UTILS+=("$(basename "$file" .sh)")
done

# Declare commands
declare -A COMMANDS
COMMANDS=(
  ["update-bees"]=""
  ["self-update"]=""
  ["backup"]="<input path> <output path> <backups to keep> [excluded directories, files separated with (,)]"
)

# Get EPX path
EPX_HOME() {
  __epx_echo "EPX path: $EPX_HOME"
}

# Main function
epx() {
  COMMAND=$1
  shift
  ARGS=("$@")

  for cmd in "${UTILS[@]}"; do
    if [[ "$COMMAND" == "$cmd" ]]; then
      "__epx_${cmd//-/_}" "${ARGS[@]}"
      return
    fi
  done

  __epx_echo "Usage: epx <command> [args]"
  for cmd in "${!COMMANDS[@]}"; do
    __epx_echo "  $cmd ${COMMANDS[$cmd]}"
  done
}

# Autocomplete
_epx_completions() {
  _autocomplete "${UTILS[*]}"
}
complete -F _epx_completions epx
