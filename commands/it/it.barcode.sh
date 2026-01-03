_cci barcode

input="${1-}"
output="${2-}"

if [[ -z "$input" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - Barcode")] Usage: $(_c LIGHT_YELLOW "it.barcode <input> [output-file]")"
  echo -e "[$(_c LIGHT_BLUE "IT - Barcode")] If output file is not specified, barcode is displayed in terminal"
  echo -e "[$(_c LIGHT_BLUE "IT - Barcode")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - Barcode")]   it.barcode '123456789'"
  echo -e "[$(_c LIGHT_BLUE "IT - Barcode")]   it.barcode 'example' barcode.png"
  exit 1
fi

if ! command -v barcode &>/dev/null; then
  if command -v python3 &>/dev/null; then
    if [[ -n "$output" ]]; then
      echo -e "[$(_c LIGHT_BLUE "IT - Barcode")] Generating barcode: $(_c LIGHT_YELLOW "$output")" >&2
      python3 << EOF
try:
    import barcode
    from barcode.writer import ImageWriter
    code = barcode.get_barcode_class('code128')('$input', writer=ImageWriter())
    code.save('${output%.*}')
    print("Barcode saved to $output")
except ImportError:
    print("Error: python-barcode package not found")
except Exception as e:
    print(f"Error: {e}")
EOF
    else
      echo -e "[$(_c LIGHT_BLUE "IT - Barcode")] $(_c LIGHT_YELLOW "Note"): Install barcode tool or python-barcode for display support" >&2
      echo -e "[$(_c LIGHT_BLUE "IT - Barcode")] $input"
    fi
  else
    echo -e "[$(_c LIGHT_BLUE "IT - Barcode")] $(_c LIGHT_RED "Error"): barcode tool or Python3 not found" >&2
    exit 1
  fi
else
  if [[ -n "$output" ]]; then
    echo -e "[$(_c LIGHT_BLUE "IT - Barcode")] Generating barcode: $(_c LIGHT_YELLOW "$output")" >&2
    barcode "$input" > "$output"

    if [[ $? -eq 0 ]]; then
      echo -e "[$(_c LIGHT_BLUE "IT - Barcode")] $(_c LIGHT_GREEN "Barcode saved to $output")" >&2
    else
      echo -e "[$(_c LIGHT_BLUE "IT - Barcode")] $(_c LIGHT_RED "Error"): Failed to generate barcode" >&2
      exit 1
    fi
  else
    echo -e "[$(_c LIGHT_BLUE "IT - Barcode")] Generating barcode..." >&2
    barcode "$input"
  fi
fi
