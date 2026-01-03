_cci curl

ip="${1:-}"

if [[ -z "$ip" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - IP Info")] Usage: $(_c LIGHT_YELLOW "it.ipinfo <ip-address>")"
  echo -e "[$(_c LIGHT_BLUE "IT - IP Info")] Retrieve information about an IP address"
  echo -e "[$(_c LIGHT_BLUE "IT - IP Info")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - IP Info")]   it.ipinfo 8.8.8.8"
  echo -e "[$(_c LIGHT_BLUE "IT - IP Info")]   it.ipinfo 1.1.1.1"
  exit 1
fi

if ! [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - IP Info")] $(_c LIGHT_RED "Error"): Invalid IP address format" >&2
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "IT - IP Info")] Fetching information for $(_c LIGHT_YELLOW "$ip")..." >&2

result=$(curl -s "https://ipapi.co/$ip/json/" 2>/dev/null)

if [[ -z "$result" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - IP Info")] $(_c LIGHT_RED "Error"): Could not fetch IP information" >&2
  exit 1
fi

echo "$result" | python3 -m json.tool 2>/dev/null || echo "$result"
echo -e "[$(_c LIGHT_BLUE "IT - IP Info")] $(_c LIGHT_GREEN "Information retrieved")" >&2
