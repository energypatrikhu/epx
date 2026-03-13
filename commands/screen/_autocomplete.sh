__epx_bash_screen_sessions() {
  local sessions
  if command -v screen >/dev/null 2>&1; then
    sessions="$(screen -list | awk '/Attached|Detached/ {print $1}' | sed 's/\t//g' | sort -u)"
  else
    sessions=""
  fi
  _autocomplete "${sessions}"
}
complete -F __epx_bash_screen_sessions screen.attach
complete -F __epx_bash_screen_sessions screen.detach
complete -F __epx_bash_screen_sessions screen.execute
complete -F __epx_bash_screen_sessions screen.kill
