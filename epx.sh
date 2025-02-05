UTILS=()
for file in /opt/epx/utils/*.sh; do
  . $file
  UTILS+=($(basename $file .sh))
done

declare -A COMMANDS
COMMANDS=(
  ["update-bees"]=""
  ["auto-update-compose"]=""
  ["self-update"]="<path>"
)

epx() {
  COMMAND=$1
  shift
  ARGS=("$@")

  for cmd in "${UTILS[@]}"; do
    if [[ "$COMMAND" == "$cmd" ]]; then
      "__${cmd//-/_}" "${ARGS[@]}"
      return
    fi
  done

  echo "Usage: epx <command> [args]"
  for cmd in "${!COMMANDS[@]}"; do
    echo "  $cmd ${COMMANDS[$cmd]}"
  done
}

_epx_completions() {
  local cur
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  COMPREPLY=($(compgen -W "${UTILS[*]}" -- "$cur"))
}

complete -F _epx_completions epx
