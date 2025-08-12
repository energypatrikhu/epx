_autocomplete() {
  local cur opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  opts="${*}"

  mapfile -t COMPREPLY < <(compgen -W "${opts}" -- "${cur}")
}
