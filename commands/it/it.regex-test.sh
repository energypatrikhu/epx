_cci grep

string="${1-}"
pattern="${2-}"

if [[ -z "$string" ]] || [[ -z "$pattern" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - Regex Test")] Usage: $(_c LIGHT_YELLOW "it.regex-test <string> <regex-pattern>")"
  echo -e "[$(_c LIGHT_BLUE "IT - Regex Test")] Test if a string matches a given regular expression"
  echo -e "[$(_c LIGHT_BLUE "IT - Regex Test")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - Regex Test")]   it.regex-test 'hello world' '^hello'"
  echo -e "[$(_c LIGHT_BLUE "IT - Regex Test")]   it.regex-test 'test@example.com' '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'"
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "IT - Regex Test")] Testing string: $(_c LIGHT_YELLOW "$string")" >&2
echo -e "[$(_c LIGHT_BLUE "IT - Regex Test")] Against pattern: $(_c LIGHT_YELLOW "$pattern")" >&2

if echo "$string" | grep -qE "$pattern"; then
  echo -e "[$(_c LIGHT_BLUE "IT - Regex Test")] $(_c LIGHT_GREEN "MATCH")"
  echo -e "[$(_c LIGHT_BLUE "IT - Regex Test")] $(_c LIGHT_GREEN "Pattern matches the string")" >&2
else
  echo -e "[$(_c LIGHT_BLUE "IT - Regex Test")] $(_c LIGHT_RED "NO MATCH")"
  echo -e "[$(_c LIGHT_BLUE "IT - Regex Test")] $(_c LIGHT_RED "Pattern does not match the string")" >&2
  exit 1
fi
