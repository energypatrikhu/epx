__epx_self_update() {
  _cci git

  if [ ! -d "${EPX_HOME}" ]; then
    echo -e "[$(_c LIGHT_BLUE "EPX - Self Update")] $(_c LIGHT_RED "The '${EPX_HOME}' directory does not exist")\n"
    return
  fi

  cd "${EPX_HOME}" || exit

  git reset --hard HEAD
  git clean -f -d
  git pull

  if [ -d "${EPX_HOME}" ]; then
    chmod -R a+x "${EPX_HOME}"
  fi

  if [ -f "${EPX_HOME}/post-install.sh" ]; then
    "${EPX_HOME}/post-install.sh"
  else
    echo -e "[$(_c LIGHT_BLUE "EPX - Self Update")] $(_c LIGHT_RED "install.sh not found, skipping post-installation steps")\n"
  fi

  echo -e "[$(_c LIGHT_BLUE "EPX - Self Update")] $(_c LIGHT_GREEN "EPX has been updated successfully")\n"

  cd - || exit
}
