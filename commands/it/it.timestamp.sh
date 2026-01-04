_help() {
  echo -e "[$(_c LIGHT_BLUE "IT - Timestamp")] Usage: $(_c LIGHT_YELLOW "it.timestamp <unix-timestamp|date-string>")"
  echo -e "[$(_c LIGHT_BLUE "IT - Timestamp")] Convert between Unix timestamp and human-readable date"
  echo -e "[$(_c LIGHT_BLUE "IT - Timestamp")]"
  echo -e "[$(_c LIGHT_BLUE "IT - Timestamp")] Options:"
  echo -e "[$(_c LIGHT_BLUE "IT - Timestamp")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "IT - Timestamp")]"
  echo -e "[$(_c LIGHT_BLUE "IT - Timestamp")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - Timestamp")]   it.timestamp 1704239400"
  echo -e "[$(_c LIGHT_BLUE "IT - Timestamp")]   it.timestamp '2024-01-03 10:00:00'"
  echo -e "[$(_c LIGHT_BLUE "IT - Timestamp")]   it.timestamp 'now'"
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

input="${1-}"
format="${2-}"

if [[ -z "$input" ]]; then
  _help
  exit 1
fi

if [[ "$input" == "now" ]]; then
  timestamp=$(date +%s)
  echo -e "[$(_c LIGHT_BLUE "IT - Timestamp")] Current Unix timestamp:" >&2
  echo "$timestamp"
  echo -e "[$(_c LIGHT_BLUE "IT - Timestamp")] Human-readable: $(date -d @"$timestamp" 2>/dev/null || date -r "$timestamp" 2>/dev/null)" >&2
elif [[ "$input" =~ ^[0-9]+$ ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - Timestamp")] Converting Unix timestamp: $(_c LIGHT_YELLOW "$input")" >&2
  date -d @"$input" 2>/dev/null || date -r "$input" 2>/dev/null
  echo -e "[$(_c LIGHT_BLUE "IT - Timestamp")] $(_c LIGHT_GREEN "Conversion complete")" >&2
else
  echo -e "[$(_c LIGHT_BLUE "IT - Timestamp")] Converting date string: $(_c LIGHT_YELLOW "$input")" >&2
  timestamp=$(date -d "$input" +%s 2>/dev/null)

  if [[ -z "$timestamp" ]]; then
    echo -e "[$(_c LIGHT_BLUE "IT - Timestamp")] $(_c LIGHT_RED "Error"): Could not parse date string" >&2
    exit 1
  fi

  echo "$timestamp"
  echo -e "[$(_c LIGHT_BLUE "IT - Timestamp")] $(_c LIGHT_GREEN "Conversion complete")" >&2
fi
