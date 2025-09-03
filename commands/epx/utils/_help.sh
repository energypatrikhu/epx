__epx_load_helps() {
  for element in "${1-}"/*; do
    if [[ -d "${element}" ]]; then
      __epx_load_helps "${element}"
      continue
    fi

    if [[ -f "${element}" && "${element}" == *.sh ]]; then
      if [[ "${element}" == *".help.sh" ]]; then
        . "${element}"
        echo
      fi
    fi
  done
}

__epx_help() {
  echo
  __epx_load_helps "${EPX_HOME}/commands"
}
