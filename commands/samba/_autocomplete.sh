__epx_bash_smb_users() {
  local users
  if command -v pdbedit &> /dev/null; then
    users="$(pdbedit -L | cut -d: -f1 | tr '\n' ' ')"
  else
    users=""
  fi
  _autocomplete "${users}"
}
complete -F __epx_bash_smb_users smb.del
