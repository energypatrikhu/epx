#!/bin/bash

# Description: Main script for the EPX CLI
# Author: EnergyPatrikHU

# Load helpers
for file in $EPX_HOME/helpers/*.sh; do
  . "$file"
done

# Load aliases
. $EPX_HOME/aliases.sh

# Load custom EPX_COMMANDS
for dir in "$EPX_HOME"/EPX_COMMANDS/*; do
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

# Command descriptions and usage as an associative array of objects
declare -A EPX_COMMANDS
EPX_COMMANDS["self-update"]="Update the EPX CLI to the latest version"
EPX_COMMANDS["update-bees"]="Update bees to the latest version"
EPX_COMMANDS["backup"]="Backup files or directories | <input path> <output path> <backups to keep> [excluded directories,files separated with (,)]"

declare -A COMMANDS
COMMANDS["c.help"]="Display help for common commands"
COMMANDS["d.help"]="Display help for Docker commands"
COMMANDS["py.help"]="Display help for Python commands"
COMMANDS["ufw.help"]="Display help for UFW commands"

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

  __epx_echo "[$(_c LIGHT_BLUE "EPX")] $(_c LIGHT_YELLOW "Usage: epx <command> [args]")"
  __epx_echo "  $(_c LIGHT_BLUE "Commands:")"
  for cmd in "${!EPX_COMMANDS[@]}"; do
    entry="${EPX_COMMANDS[$cmd]}"
    desc=$(echo "$entry" | awk -F'|' '{print $1}' | xargs)
    usage=$(echo "$entry" | awk -F'|' '{print $2}' | xargs)
    __epx_echo "    $(_c LIGHT_BLUE "$cmd") - $desc"
    if [[ -n "$usage" ]]; then
      __epx_echo "      $(_c LIGHT_YELLOW "Usage:") epx $cmd $usage"
    fi
  done
  __epx_echo "  $(_c LIGHT_BLUE "Aliases:")"
  __epx_echo "    $(_c LIGHT_BLUE "epx") - Main entrypoint for all epx commands"

  __epx_echo "  $(_c LIGHT_BLUE "Helpers:")"
  for cmd in "${!COMMANDS[@]}"; do
    desc="${COMMANDS[$cmd]}"
    __epx_echo "    $(_c LIGHT_BLUE "$cmd") - $desc"
  done
}

# Autocomplete
_epx_completions() {
  _autocomplete "${UTILS[*]}"
}
complete -F _epx_completions epx
