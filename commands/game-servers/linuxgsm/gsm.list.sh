_help() {
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] Usage: $(_c LIGHT_YELLOW "gsm.list [search-term]")"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] List available LinuxGSM game servers"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] Options:"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]   gsm.list"
  echo -e "[$(_c LIGHT_BLUE "LinuxGSM")]   gsm.list cs2"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

available_servers="$(curl -sL https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/refs/heads/master/lgsm/data/serverlist.csv | awk -F',' '{print $1","$3}' | tail -n +2)"
opt_find=""
if [[ -n "${1-}" ]]; then
  opt_find="${1}"
  available_servers="$(echo "${available_servers}" | awk -F',' -v search="${opt_find}" 'tolower($1) ~ tolower(search) || tolower($2) ~ tolower(search)')"
fi

echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_GREEN "Available game servers:")"
echo "${available_servers}" | while IFS=, read -r shortname gamename; do
  echo -e "  $(_c LIGHT_YELLOW "${gamename}") $(_c LIGHT_CYAN "(${shortname})")"
done
