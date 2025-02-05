# Description: Main script for the EPX CLI
# Author: EnergyPatrikHU

# Set the EPX path
export EPX_PATH="/opt/epx"

# Load aliases
. $EPX_PATH/aliases.sh

# Load custom commands
for dir in $EPX_PATH/commands/*; do
  if [ -d $dir ]; then
    for file in $dir/*.sh; do
      # skip file if start with an underscore
      [[ $(basename $file) =~ ^_ ]] && continue

      . $file
    done
  fi
done

for file in $EPX_PATH/commands/*.sh; do
  . $file
done

# Load all utils
UTILS=()
for file in $EPX_PATH/utils/*.sh; do
  . $file
  UTILS+=($(basename $file .sh))
done

# Declare commands
declare -A COMMANDS
COMMANDS=(
  ["update-bees"]=""
  ["auto-update-compose"]=""
  ["self-update"]=""
)

# Get EPX path
epx_path() {
  echo "EPX path: $EPX_PATH"
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

  echo "Usage: epx <command> [args]"
  for cmd in "${!COMMANDS[@]}"; do
    echo "  $cmd ${COMMANDS[$cmd]}"
  done
}

# Autocomplete
_epx_completions() {
  local cur
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  COMPREPLY=($(compgen -W "${UTILS[*]}" -- "$cur"))
}

complete -F _epx_completions epx
