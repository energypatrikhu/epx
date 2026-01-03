_help() {
  echo -e "[$(_c LIGHT_BLUE "IT - Random String")] Usage: $(_c LIGHT_YELLOW "it.rnd-string [length]")"
  echo -e "[$(_c LIGHT_BLUE "IT - Random String")] Generate a random alphanumeric string of specified length"
  echo -e "[$(_c LIGHT_BLUE "IT - Random String")] Default length: $(_c LIGHT_YELLOW "16")"
  echo -e "[$(_c LIGHT_BLUE "IT - Random String")]"
  echo -e "[$(_c LIGHT_BLUE "IT - Random String")] Options:"
  echo -e "[$(_c LIGHT_BLUE "IT - Random String")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "IT - Random String")]"
  echo -e "[$(_c LIGHT_BLUE "IT - Random String")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - Random String")]   it.rnd-string 32"
  echo -e "[$(_c LIGHT_BLUE "IT - Random String")]   it.rnd-string"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "IT - Barcode")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci openssl

length="${1:-16}"

if ! [[ "$length" =~ ^[0-9]+$ ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - Random String")] $(_c LIGHT_RED "Error"): Length must be a positive integer"
  exit 1
fi

if [[ $length -lt 1 ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - Random String")] $(_c LIGHT_RED "Error"): Length must be at least 1"
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "IT - Random String")] Generating random string ($(_c LIGHT_YELLOW "$length") chars)..."
random_string=$(openssl rand -base64 "$length" | tr -d '\n=+/' | cut -c1-"$length")

echo "$random_string"
echo -e "[$(_c LIGHT_BLUE "IT - Random String")] $(_c LIGHT_GREEN "Random string generated successfully")" >&2
