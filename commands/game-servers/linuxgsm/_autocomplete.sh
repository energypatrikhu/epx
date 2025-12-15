_gsm_autocomplete() {
  local containers
  containers="$(docker ps -a --format '{{.Names}}' | grep '^linuxgsm-' | sed 's/^linuxgsm-//')"
  _autocomplete "${containers}"
}
complete -F _gsm_autocomplete gsm
