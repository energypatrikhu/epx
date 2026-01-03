_cci python3

mode="${1-}"
input="${2-}"

if [[ -z "$input" || -z "$mode" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - HTML Encode")] Usage: $(_c LIGHT_YELLOW "it.htmlencode <string> [encode|decode]")"
  echo -e "[$(_c LIGHT_BLUE "IT - HTML Encode")] Default mode: $(_c LIGHT_YELLOW "encode")"
  echo -e "[$(_c LIGHT_BLUE "IT - HTML Encode")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - HTML Encode")]   it.htmlencode encode '<hello>world</hello>'"
  echo -e "[$(_c LIGHT_BLUE "IT - HTML Encode")]   it.htmlencode decode '&lt;hello&gt;'"
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
