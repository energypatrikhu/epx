_help() {
  echo -e "[$(_c LIGHT_BLUE "IT - Timezone")] Usage: $(_c LIGHT_YELLOW "it.timezone [timezone]")"
  echo -e "[$(_c LIGHT_BLUE "IT - Timezone")] Display current time in specified timezone"
  echo -e "[$(_c LIGHT_BLUE "IT - Timezone")] If no timezone specified, shows common timezones"
  echo -e "[$(_c LIGHT_BLUE "IT - Timezone")]"
  echo -e "[$(_c LIGHT_BLUE "IT - Timezone")] Options:"
  echo -e "[$(_c LIGHT_BLUE "IT - Timezone")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "IT - Timezone")]"
  echo -e "[$(_c LIGHT_BLUE "IT - Timezone")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - Timezone")]   it.timezone UTC"
  echo -e "[$(_c LIGHT_BLUE "IT - Timezone")]   it.timezone 'America/New_York'"
  echo -e "[$(_c LIGHT_BLUE "IT - Timezone")]   it.timezone 'Asia/Tokyo'"
  echo -e ""
  echo -e "[$(_c LIGHT_BLUE "IT - Timezone")] Common timezones:"
  for tz in UTC America/New_York Europe/London Europe/Budapest Asia/Tokyo Australia/Sydney; do
    TZ="$tz" date +"[$(_c LIGHT_BLUE "IT - Timezone")]   $(_c LIGHT_YELLOW "$tz"): %Y-%m-%d %H:%M:%S"
  done
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg date:coreutils

timezone="${1-}"

if [[ -z "$timezone" ]]; then
  _help
  exit 1
fi

if TZ="$timezone" date &>/dev/null; then
  echo -e "[$(_c LIGHT_BLUE "IT - Timezone")] Time in $(_c LIGHT_YELLOW "$timezone"):" >&2
  TZ="$timezone" date "+%Y-%m-%d %H:%M:%S %Z"
  echo -e "[$(_c LIGHT_BLUE "IT - Timezone")] $(_c LIGHT_GREEN "Timezone displayed")" >&2
else
  echo -e "[$(_c LIGHT_BLUE "IT - Timezone")] $(_c LIGHT_RED "Error"): Invalid timezone '$timezone'" >&2
  exit 1
fi
