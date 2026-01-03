_help() {
  echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] Usage: $(_c LIGHT_YELLOW "it.qr <input> [output-file]")"
  echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] If output file is not specified, QR code is displayed in terminal"
  echo -e "[$(_c LIGHT_BLUE "IT - QR Code")]"
  echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] Options:"
  echo -e "[$(_c LIGHT_BLUE "IT - QR Code")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "IT - QR Code")]"
  echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - QR Code")]   it.qr 'https://example.com'"
  echo -e "[$(_c LIGHT_BLUE "IT - QR Code")]   it.qr 'hello world' qrcode.png"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci qrencode

input="${1-}"
output="${2-}"

if [[ -z "$input" ]]; then
  _help
  exit 1
fi

if ! command -v qrencode &>/dev/null; then
  echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] $(_c LIGHT_RED "Error"): qrencode not found, attempting to use Python..." >&2

  if command -v python3 &>/dev/null; then
    if [[ -n "$output" ]]; then
      echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] Generating QR code: $(_c LIGHT_YELLOW "$output")" >&2
      python3 << EOF
import qrcode
qr = qrcode.QRCode()
qr.add_data("$input")
qr.make()
qr.make_image().save("$output")
EOF

      if [[ $? -eq 0 ]]; then
        echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] $(_c LIGHT_GREEN "QR code saved to $output")" >&2
      else
        echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] $(_c LIGHT_RED "Error"): Failed to generate QR code" >&2
        exit 1
      fi
    else
      echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] Generating QR code in terminal..." >&2
      python3 << EOF
import qrcode
qr = qrcode.QRCode()
qr.add_data("$input")
qr.make()
qr.print_ascii()
EOF

      if [[ $? -eq 0 ]]; then
        echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] $(_c LIGHT_GREEN "QR code generated")" >&2
      else
        echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] $(_c LIGHT_RED "Error"): Failed to generate QR code" >&2
        exit 1
      fi
    fi
  else
    echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] $(_c LIGHT_RED "Error"): qrencode and Python3 not found" >&2
    exit 1
  fi
else
  if [[ -n "$output" ]]; then
    echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] Generating QR code: $(_c LIGHT_YELLOW "$output")" >&2
    qrencode -o "$output" "$input"

    if [[ $? -eq 0 ]]; then
      echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] $(_c LIGHT_GREEN "QR code saved to $output")" >&2
    else
      echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] $(_c LIGHT_RED "Error"): Failed to generate QR code" >&2
      exit 1
    fi
  else
    echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] Generating QR code in terminal..." >&2
    qrencode -t ANSI "$input"

    if [[ $? -eq 0 ]]; then
      echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] $(_c LIGHT_GREEN "QR code generated")" >&2
    else
      echo -e "[$(_c LIGHT_BLUE "IT - QR Code")] $(_c LIGHT_RED "Error"): Failed to generate QR code" >&2
      exit 1
    fi
  fi
fi
