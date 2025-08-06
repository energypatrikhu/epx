#!/bin/bash

if command -v eza &> /dev/null; then
  /usr/bin/eza -lagh --git --octal-permissions "$@"
elif command -v exa &> /dev/null; then
  /usr/bin/exa -lagh --git --octal-permissions "$@"
else
  /usr/bin/ls -lah "$@"
fi
