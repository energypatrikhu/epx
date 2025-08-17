

if command -v eza &> /dev/null; then
  eza --all --long --group --header --icons=always --no-permissions --tree --level=1 "$@"
elif command -v exa &> /dev/null; then
  exa --all --long --group --header --icons=always --no-permissions --tree --level=1 "$@"
else
  /bin/ls --all --format=long --human-readable "$@"
fi
