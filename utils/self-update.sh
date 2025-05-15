#!/bin/bash

__epx_self_update() {
  if [ ! -d "$EPX_PATH" ]; then
    __epx_echo "[$(_c LIGHT_BLUE "Self Update")] $(_c LIGHT_RED "The '$EPX_PATH' directory does not exist")\n"
    return
  fi

  cd "$EPX_PATH" || return

  git reset --hard HEAD
  git clean -f -d
  git pull

  cd - || return

  if [ -f "$EPX_PATH" ]; then
    chmod +x -R "$EPX_PATH"
  fi

  source "$HOME/.bashrc" || return
}
