function __epx_fish_screen_sessions
  if command -v screen >/dev/null 2>&1
    screen -list | awk '/Attached|Detached/ {print $1}' | sed 's/\t//g' | sort -u
  else
    echo ""
  end
end

complete -c screen.attach -f -a '(__epx_fish_screen_sessions)'
complete -c screen.detach -f -a '(__epx_fish_screen_sessions)'
complete -c screen.execute -f -a '(__epx_fish_screen_sessions)'
complete -c screen.kill -f -a '(__epx_fish_screen_sessions)'
