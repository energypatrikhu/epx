_cci base64

input="${1-}"
mode="${2-}"

if [[ -z "$input" ]] || [[ -z "$mode" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - Base64")] Usage: $(_c LIGHT_YELLOW "it.b64 <string|file> [encode|decode]")"
  echo -e "[$(_c LIGHT_BLUE "IT - Base64")] Default mode: $(_c LIGHT_YELLOW "encode")"
  echo -e "[$(_c LIGHT_BLUE "IT - Base64")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - Base64")]   it.b64 decode 'aGVsbG8gd29ybGQ='"
  echo -e "[$(_c LIGHT_BLUE "IT - Base64")]   it.b64 encode /path/to/file"
  exit 1
fi

if [[ -z "$mode" ]]; then
  mode="encode"
fi

if [[ "$mode" != "encode" ]] && [[ "$mode" != "decode" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - Base64")] $(_c LIGHT_RED "Error"): Invalid mode '$mode'. Use 'encode' or 'decode'"
  exit 1
fi

if [[ -f "$input" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - Base64")] File mode: $(_c LIGHT_YELLOW "$input")"

  if [[ "$mode" == "encode" ]]; then
    echo -e "[$(_c LIGHT_BLUE "IT - Base64")] Encoding file..."
    base64 < "$input"
    if [[ $? -eq 0 ]]; then
      echo -e "" >&2
      echo -e "[$(_c LIGHT_BLUE "IT - Base64")] $(_c LIGHT_GREEN "File encoded successfully")" >&2
    fi
  else
    echo -e "[$(_c LIGHT_BLUE "IT - Base64")] Decoding file..."
    base64 -d < "$input"
    if [[ $? -eq 0 ]]; then
      echo -e "" >&2
      echo -e "[$(_c LIGHT_BLUE "IT - Base64")] $(_c LIGHT_GREEN "File decoded successfully")" >&2
    fi
  fi
else
  echo -e "[$(_c LIGHT_BLUE "IT - Base64")] String mode"
  if [[ "$mode" == "encode" ]]; then
    echo -e "[$(_c LIGHT_BLUE "IT - Base64")] Encoding string..."
    echo -n "$input" | base64
    echo ""
    echo -e "[$(_c LIGHT_BLUE "IT - Base64")] $(_c LIGHT_GREEN "String encoded successfully")" >&2
  else
    echo -e "[$(_c LIGHT_BLUE "IT - Base64")] Decoding string..."
    echo -n "$input" | base64 -d
    echo ""
    echo -e "[$(_c LIGHT_BLUE "IT - Base64")] $(_c LIGHT_GREEN "String decoded successfully")" >&2
  fi
fi
