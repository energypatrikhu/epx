#!/bin/bash

if command -v eza &> /dev/null; then
  /bin/eza --all --long --group --header --git --octal-permissions --tree --level=1 "$@"
elif command -v exa &> /dev/null; then
  /bin/exa --all --long --group --header --git --octal-permissions --tree --level=1 "$@"
else
  /bin/ls --all --format=long --human-readable "$@"
fi
