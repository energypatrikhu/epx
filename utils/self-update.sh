#!/bin/bash

__epx_self_update() {
  if [ ! -d "$EPX_PATH" ]; then
    printf "%s\n" "[$(_c LIGHT_BLUE "Self Update")] $(_c LIGHT_RED "The '$EPX_PATH' directory does not exist")\n"
    return
  fi

  cd "$EPX_PATH" || return

  git reset --hard HEAD
  git clean -f -d
  git pull

  cd - || return

  if [ -f "$EPX_PATH/epx" ]; then
    chmod +x "$EPX_PATH/epx"
  fi

  source "$HOME/.bashrc" || return
}
