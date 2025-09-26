_cci ufw

if [[ -z "${1-}" ]]; then
  ufw status
  exit
fi

case "${1,,}" in
  on|enable)
    ufw enable
    ;;
  off|disable)
    ufw disable
    ;;
  *)
    echo -e "[$(_c LIGHT_CYAN "UFW")] $(_c LIGHT_YELLOW "Usage: ufw.status <[on|enable] | [off|disable]>")"
    exit 1
    ;;
esac
