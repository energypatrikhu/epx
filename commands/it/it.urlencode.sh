_help() {
  echo -e "[$(_c LIGHT_BLUE "IT - URL Encode")] Usage: $(_c LIGHT_YELLOW "it.urlencode <string> [encode|decode]")"
  echo -e "[$(_c LIGHT_BLUE "IT - URL Encode")] Default mode: $(_c LIGHT_YELLOW "encode")"
  echo -e "[$(_c LIGHT_BLUE "IT - URL Encode")]"
  echo -e "[$(_c LIGHT_BLUE "IT - URL Encode")] Options:"
  echo -e "[$(_c LIGHT_BLUE "IT - URL Encode")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "IT - URL Encode")]"
  echo -e "[$(_c LIGHT_BLUE "IT - URL Encode")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - URL Encode")]   it.urlencode encode 'hello world'"
  echo -e "[$(_c LIGHT_BLUE "IT - URL Encode")]   it.urlencode decode 'hello%20world'"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "IT - URL Encode")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg python3:python3-minimal

mode="${1-}"
input="${2-}"

if [[ -z "$input" ]] || [[ -z "$mode" ]]; then
  _help
  exit 1
fi

if [[ "$mode" != "encode" ]] && [[ "$mode" != "decode" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - URL Encode")] $(_c LIGHT_RED "Error"): Invalid mode '$mode'. Use 'encode' or 'decode'" >&2
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "IT - URL Encode")] ${mode^}ing string..." >&2

if [[ "$mode" == "encode" ]]; then
  python3 << EOF
from urllib.parse import quote
print(quote("$input"))
EOF
else
  python3 << EOF
from urllib.parse import unquote
print(unquote("$input"))
EOF
fi

echo -e "[$(_c LIGHT_BLUE "IT - URL Encode")] $(_c LIGHT_GREEN "${mode^} complete")" >&2
