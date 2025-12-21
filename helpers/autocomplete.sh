# Detect the current shell
_epx_detect_shell() {
  if [ -n "$FISH_VERSION" ]; then
    echo "fish"
  elif [ -n "$BASH_VERSION" ]; then
    echo "bash"
  else
    echo "unknown"
  fi
}

# Bash autocomplete function
_autocomplete() {
  local cur opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  opts="${*}"

  mapfile -t COMPREPLY < <(compgen -W "${opts}" -- "${cur}")
}

# Fish autocomplete helper - generates completion entries
_autocomplete_fish() {
  local cmd="$1"
  shift
  local opts="$*"

  for opt in $opts; do
    echo "complete -c $cmd -a '$opt'"
  done
}
