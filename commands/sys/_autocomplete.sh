__epx_sys_services() {
  local services
  if command -v systemctl &> /dev/null; then
    services="$(systemctl list-units --type=service --all --no-legend --plain | awk '{print $1}' | sed 's/\.service$//' | sort -u)"
  else
    services=""
  fi
  _autocomplete "${services}"
}
complete -F __epx_sys_services sys.disable
complete -F __epx_sys_services sys.enable
complete -F __epx_sys_services sys.remove
complete -F __epx_sys_services sys.restart
complete -F __epx_sys_services sys.start
complete -F __epx_sys_services sys.status
complete -F __epx_sys_services sys.stop
