__epx_self_update_logging() {
  filename="/var/log/epx/self-update.log"

  if [ ! -d "/var/log/epx" ]; then
    echo -e "[$(_c LIGHT_BLUE "EPX - Self Update")] $(_c LIGHT_RED "Log directory '/var/log/epx' does not exist and could not be created")"

    if ! mkdir -p "/var/log/epx"; then
      echo -e "[$(_c LIGHT_BLUE "EPX - Self Update")] $(_c LIGHT_RED "Failed to create log directory '/var/log/epx'")"
      return 1
    fi
  fi

  echo -e "$1" >> "${filename}"
}

__epx_self_update() {
  echo -e "[$(_c LIGHT_BLUE "EPX - Self Update")] $(_c LIGHT_YELLOW "Starting EPX self-update process...")"
  __epx_self_update_logging "\nSelf Update - $(date +'%Y-%m-%d %H:%M:%S')"

  _cci git

  if [ ! -d "${EPX_HOME}" ]; then
    echo -e "[$(_c LIGHT_BLUE "EPX - Self Update")] $(_c LIGHT_RED "The '${EPX_HOME}' directory does not exist")"
    __epx_self_update_logging "Directory '${EPX_HOME}' does not exist"
    return
  fi

  cd "${EPX_HOME}" || exit

  __epx_self_update_logging "Running git reset --hard HEAD"
  git reset --hard HEAD 2>&1 | while IFS= read -r line; do __epx_self_update_logging "$line"; done

  __epx_self_update_logging "Running git clean -f -d"
  git clean -f -d 2>&1 | while IFS= read -r line; do __epx_self_update_logging "$line"; done

  __epx_self_update_logging "Running git pull"
  git pull 2>&1 | while IFS= read -r line; do __epx_self_update_logging "$line"; done

  if [ -d "${EPX_HOME}" ]; then
    __epx_self_update_logging "Setting permissions on ${EPX_HOME}"
    chmod -R a+x "${EPX_HOME}" 2>&1 | while IFS= read -r line; do __epx_self_update_logging "$line"; done
  fi

  if [ -f "${EPX_HOME}/post-install.sh" ]; then
    __epx_self_update_logging "Running post-install script"
    "${EPX_HOME}/post-install.sh" 2>&1 | while IFS= read -r line; do __epx_self_update_logging "$line"; done
  else
    echo -e "[$(_c LIGHT_BLUE "EPX - Self Update")] $(_c LIGHT_RED "install.sh not found, skipping post-installation steps")"
    __epx_self_update_logging "Post-install script not found, skipping"
  fi

  echo -e "[$(_c LIGHT_BLUE "EPX - Self Update")] $(_c LIGHT_GREEN "EPX has been updated successfully")"
  __epx_self_update_logging "EPX updated successfully"

  cd - || exit
}
