_cci grep

string="$1"
pattern="$2"

if [[ -z "$string" ]] || [[ -z "$pattern" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - Regex Extract")] Usage: $(_c LIGHT_YELLOW "it.regex-extract <string> <regex-pattern>")"
  echo -e "[$(_c LIGHT_BLUE "IT - Regex Extract")] Extract substrings from a string using regular expression"
  echo -e "[$(_c LIGHT_BLUE "IT - Regex Extract")] Use capture groups () to extract specific parts"
  echo -e "[$(_c LIGHT_BLUE "IT - Regex Extract")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - Regex Extract")]   it.regex-extract 'user@example.com' '([a-zA-Z0-9._%+-]+)@'"
  echo -e "[$(_c LIGHT_BLUE "IT - Regex Extract")]   it.regex-extract 'ID: 12345' 'ID: ([0-9]+)'"
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "IT - Regex Extract")] Extracting from: $(_c LIGHT_YELLOW "$string")" >&2
echo -e "[$(_c LIGHT_BLUE "IT - Regex Extract")] Using pattern: $(_c LIGHT_YELLOW "$pattern")" >&2

matches=$(echo "$string" | grep -oE "$pattern" || true)

if [[ -z "$matches" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - Regex Extract")] $(_c LIGHT_RED "No matches found")"
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "IT - Regex Extract")] $(_c LIGHT_GREEN "Matches found:"):"
echo "$matches"
echo -e "[$(_c LIGHT_BLUE "IT - Regex Extract")] $(_c LIGHT_GREEN "Extraction complete")" >&2
