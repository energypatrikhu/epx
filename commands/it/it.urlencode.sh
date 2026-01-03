_cci python3

input="$1"
mode="${2:-encode}"

if [[ -z "$input" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - URL Encode")] Usage: $(_c LIGHT_YELLOW "it.urlencode <string> [encode|decode]")"
  echo -e "[$(_c LIGHT_BLUE "IT - URL Encode")] Default mode: $(_c LIGHT_YELLOW "encode")"
  echo -e "[$(_c LIGHT_BLUE "IT - URL Encode")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - URL Encode")]   it.urlencode 'hello world'"
  echo -e "[$(_c LIGHT_BLUE "IT - URL Encode")]   it.urlencode 'hello%20world' decode"
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
