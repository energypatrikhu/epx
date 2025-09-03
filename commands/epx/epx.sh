
declare -A EPX_UTILS
EPX_UTILS["self-update"]="Update the EPX CLI to the latest version"
source "${EPX_HOME}/commands/epx/utils/_self-update.sh"

EPX_UTILS["mk-cert"]="Create a self-signed SSL certificate | <domain>"
source "${EPX_HOME}/commands/epx/utils/_mk-cert.sh"

EPX_UTILS["update-bees"]="Update bees to the latest version"
source "${EPX_HOME}/commands/epx/utils/_update-bees.sh"

EPX_UTILS["backup"]="Backup files or directories | <input path> <output path> <backups to keep> [excluded directories,files separated with (,)]"
source "${EPX_HOME}/commands/epx/utils/_backup.sh"

EPX_UTILS["help"]="Display help information for EPX commands"
source "${EPX_HOME}/commands/epx/utils/_help.sh"

# ---------------------------------------------------------------------------------------------------------------------------- #

COMMAND="${1-}"
ARGS=("${@:2}")

for cmd in "${!EPX_UTILS[@]}"; do
  if [[ "${COMMAND}" == "${cmd}" ]]; then
    "__epx_${cmd//-/_}" "${ARGS[@]}"
    exit
  fi
done

echo -e "[$(_c LIGHT_BLUE "EPX")] $(_c LIGHT_YELLOW "Usage: epx <command> [args]")"
echo -e "  $(_c CYAN "Commands:")"
for cmd in "${!EPX_UTILS[@]}"; do
  entry="${EPX_UTILS[${cmd}]}"
  desc=$(echo "${entry}" | awk -F'|' '{print $1}' | xargs)
  usage=$(echo "${entry}" | awk -F'|' '{print $2}' | xargs)
  echo -e "    $(_c LIGHT_CYAN "${cmd}") - ${desc}"
  if [[ -n "${usage}" ]]; then
    echo -e "      $(_c LIGHT_YELLOW "Usage:") epx ${cmd} ${usage}"
  fi
done

__epx_help
