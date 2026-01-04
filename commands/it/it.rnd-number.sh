_help() {
  echo -e "[$(_c LIGHT_BLUE "IT - Random Number")] Usage: $(_c LIGHT_YELLOW "it.rnd-number [start] [end]")"
  echo -e "[$(_c LIGHT_BLUE "IT - Random Number")] Generate a random number between the specified start and end values (inclusive)."
  echo -e "[$(_c LIGHT_BLUE "IT - Random Number")] If no values are provided, defaults to 1 and 100."
  echo -e "[$(_c LIGHT_BLUE "IT - Random Number")]"
  echo -e "[$(_c LIGHT_BLUE "IT - Random Number")] Options:"
  echo -e "[$(_c LIGHT_BLUE "IT - Random Number")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "IT - Random Number")]"
  echo -e "[$(_c LIGHT_BLUE "IT - Random Number")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - Random Number")]   it.rnd-number 10 50"
  echo -e "[$(_c LIGHT_BLUE "IT - Random Number")]   it.rnd-number"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

source "${EPX_HOME}/helpers/random-number.sh"

start="${1:-1}"
end="${2:-100}"

if ! [[ "$start" =~ ^-?[0-9]+$ ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - Random Number")] $(_c LIGHT_RED "Error"): Start value must be an integer" >&2
  exit 1
fi

if ! [[ "$end" =~ ^-?[0-9]+$ ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - Random Number")] $(_c LIGHT_RED "Error"): End value must be an integer" >&2
  exit 1
fi

if [[ $start -gt $end ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - Random Number")] $(_c LIGHT_RED "Error"): Start value cannot be greater than end value" >&2
  exit 1
fi

range=$((end - start + 1))
rnd_val=$(_rnd_number)
random_number=$((rnd_val % range + start))

echo -e "[$(_c LIGHT_BLUE "IT - Random Number")] Generating random number between $(_c LIGHT_YELLOW "$start") and $(_c LIGHT_YELLOW "$end")..." >&2

echo "$random_number"
echo -e "[$(_c LIGHT_BLUE "IT - Random Number")] $(_c LIGHT_GREEN "Random number generated")" >&2
