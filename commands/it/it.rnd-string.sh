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
