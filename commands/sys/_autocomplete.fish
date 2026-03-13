function __epx_fish_sys_services
  if command -v systemctl &> /dev/null
    systemctl list-units --type=service --all --no-legend --plain | awk '{print $1}' | sed 's/\.service$//' | sort -u
  else
    echo ""
  end
end

complete -c sys.disable -f -a '(__epx_fish_sys_services)'
complete -c sys.enable -f -a '(__epx_fish_sys_services)'
complete -c sys.remove -f -a '(__epx_fish_sys_services)'
complete -c sys.restart -f -a '(__epx_fish_sys_services)'
complete -c sys.start -f -a '(__epx_fish_sys_services)'
complete -c sys.status -f -a '(__epx_fish_sys_services)'
complete -c sys.stop -f -a '(__epx_fish_sys_services)'

complete -c sys.list -f -a 'active inactive failed activating deactivating'
