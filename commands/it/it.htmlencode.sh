_cci python3

input="$1"
mode="${2:-encode}"

if [[ -z "$input" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - HTML Encode")] Usage: $(_c LIGHT_YELLOW "it.htmlencode <string> [encode|decode]")"
  echo -e "[$(_c LIGHT_BLUE "IT - HTML Encode")] Default mode: $(_c LIGHT_YELLOW "encode")"
  echo -e "[$(_c LIGHT_BLUE "IT - HTML Encode")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - HTML Encode")]   it.htmlencode '<hello>world</hello>'"
  echo -e "[$(_c LIGHT_BLUE "IT - HTML Encode")]   it.htmlencode '&lt;hello&gt;' decode"
  exit 1
fi

if [[ "$mode" != "encode" ]] && [[ "$mode" != "decode" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - HTML Encode")] $(_c LIGHT_RED "Error"): Invalid mode '$mode'. Use 'encode' or 'decode'" >&2
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "IT - HTML Encode")] ${mode^}ing string..." >&2

if [[ "$mode" == "encode" ]]; then
  python3 << EOF
import html
print(html.escape("$input"))
EOF
else
  python3 << EOF
import html
print(html.unescape("$input"))
EOF
fi

echo -e "[$(_c LIGHT_BLUE "IT - HTML Encode")] $(_c LIGHT_GREEN "${mode^} complete")" >&2
