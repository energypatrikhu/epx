_help() {
  echo -e "[$(_c LIGHT_BLUE "IT - User Agent")] Usage: $(_c LIGHT_YELLOW "it.useragent <user-agent-string>")"
  echo -e "[$(_c LIGHT_BLUE "IT - User Agent")] Parse and display information from a user-agent string"
  echo -e "[$(_c LIGHT_BLUE "IT - User Agent")]"
  echo -e "[$(_c LIGHT_BLUE "IT - User Agent")] Options:"
  echo -e "[$(_c LIGHT_BLUE "IT - User Agent")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "IT - User Agent")]"
  echo -e "[$(_c LIGHT_BLUE "IT - User Agent")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - User Agent")]   it.useragent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "IT - User Agent")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg sed:sed

useragent="${1-}"

if [[ -z "$useragent" ]]; then
  _help
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "IT - User Agent")] Parsing user-agent string..." >&2

echo -e "[$(_c LIGHT_BLUE "IT - User Agent")] $(_c LIGHT_YELLOW "Raw"): $useragent"

if [[ "$useragent" =~ Mozilla ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - User Agent")] $(_c LIGHT_YELLOW "Type"): Browser"
fi

if [[ "$useragent" =~ Windows ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - User Agent")] $(_c LIGHT_YELLOW "OS"): Windows"
elif [[ "$useragent" =~ Macintosh ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - User Agent")] $(_c LIGHT_YELLOW "OS"): macOS"
elif [[ "$useragent" =~ Linux ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - User Agent")] $(_c LIGHT_YELLOW "OS"): Linux"
elif [[ "$useragent" =~ iPhone ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - User Agent")] $(_c LIGHT_YELLOW "OS"): iOS"
elif [[ "$useragent" =~ Android ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - User Agent")] $(_c LIGHT_YELLOW "OS"): Android"
fi

if [[ "$useragent" =~ Chrome ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - User Agent")] $(_c LIGHT_YELLOW "Browser"): Chrome"
elif [[ "$useragent" =~ Firefox ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - User Agent")] $(_c LIGHT_YELLOW "Browser"): Firefox"
elif [[ "$useragent" =~ Safari ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - User Agent")] $(_c LIGHT_YELLOW "Browser"): Safari"
elif [[ "$useragent" =~ Edge ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - User Agent")] $(_c LIGHT_YELLOW "Browser"): Edge"
fi

echo -e "[$(_c LIGHT_BLUE "IT - User Agent")] $(_c LIGHT_GREEN "Parsing complete")" >&2
