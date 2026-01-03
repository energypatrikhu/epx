_cci date

start="${1:-1}"
end="${2:-100}"

if ! [[ "$start" =~ ^-?[0-9]+$ ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - Random Number")] $(_c LIGHT_RED "Error"): Start value must be an integer"
  exit 1
fi

if ! [[ "$end" =~ ^-?[0-9]+$ ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - Random Number")] $(_c LIGHT_RED "Error"): End value must be an integer"
  exit 1
fi

if [[ $start -gt $end ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - Random Number")] $(_c LIGHT_RED "Error"): Start value cannot be greater than end value"
  exit 1
fi

range=$((end - start + 1))

random_number=$((RANDOM % range + start))

echo -e "[$(_c LIGHT_BLUE "IT - Random Number")] Generating random number between $(_c LIGHT_YELLOW "$start") and $(_c LIGHT_YELLOW "$end")..."

echo "$random_number"
echo -e "[$(_c LIGHT_BLUE "IT - Random Number")] $(_c LIGHT_GREEN "Random number generated")" >&2
