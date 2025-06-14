#!/bin/bash

__epx_self_update() {
  if [ ! -d "$EPX_PATH" ]; then
    __epx_echo "[$(_c LIGHT_BLUE "EPX - Self Update")] $(_c LIGHT_RED "The '$EPX_PATH' directory does not exist")\n"
    return
  fi

  cd "$EPX_PATH" || return

  git reset --hard HEAD
  git clean -f -d
  git pull

  cd - || return

  if [ -d "$EPX_PATH" ]; then
    chmod -R a+x "$EPX_PATH"
  fi

  if [ -f "$EPX_PATH/post-install.sh" ]; then
    "$EPX_PATH/post-install.sh"
  else
    __epx_echo "[$(_c LIGHT_BLUE "EPX - Self Update")] $(_c LIGHT_RED "install.sh not found, skipping post-installation steps")\n"
  fi
}
