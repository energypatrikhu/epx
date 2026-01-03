if [ -f "/usr/share/bash-completion/completions/systemctl" ]; then
  source /usr/share/bash-completion/completions/systemctl
  complete -F _systemctl sctl
  complete -F _systemctl sys
fi

if [ -f "/usr/share/bash-completion/completions/journalctl" ]; then
  source /usr/share/bash-completion/completions/journalctl
  complete -F _journalctl jctl
fi
