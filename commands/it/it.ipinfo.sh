_cci curl

ip="${1-}"

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

extract_field() {
  echo "$result" | grep -o "\"$1\":[^,}]*" | cut -d':' -f2- | sed 's/^[[:space:]]*"//;s/"[[:space:]]*$//'
}

echo
echo -e "$(_c LIGHT_BLUE "============================================================")"
echo -e "$(_c LIGHT_CYAN " IP Information for $(extract_field ip) ")"
echo -e "$(_c LIGHT_BLUE "============================================================")"
echo

echo -e "$(_c LIGHT_YELLOW "IP Details:")"
echo -e "  $(_c LIGHT_CYAN "IP Address     ") $(extract_field ip)"
echo -e "  $(_c LIGHT_CYAN "Version        ") $(extract_field version)"
echo -e "  $(_c LIGHT_CYAN "Network        ") $(extract_field network)"
echo

echo -e "$(_c LIGHT_YELLOW "Location:")"
echo -e "  $(_c LIGHT_CYAN "City           ") $(extract_field city)"
echo -e "  $(_c LIGHT_CYAN "Region         ") $(extract_field region) ($(extract_field region_code))"
echo -e "  $(_c LIGHT_CYAN "Country        ") $(extract_field country_name) ($(extract_field country_code))"
echo -e "  $(_c LIGHT_CYAN "Capital        ") $(extract_field country_capital)"
echo -e "  $(_c LIGHT_CYAN "Continent      ") $(extract_field continent_code)"
echo -e "  $(_c LIGHT_CYAN "Postal Code    ") $(extract_field postal)"
echo -e "  $(_c LIGHT_CYAN "Timezone       ") $(extract_field timezone) ($(extract_field utc_offset))"
echo

echo -e "$(_c LIGHT_YELLOW "Coordinates:")"
echo -e "  $(_c LIGHT_CYAN "Latitude       ") $(extract_field latitude)"
echo -e "  $(_c LIGHT_CYAN "Longitude      ") $(extract_field longitude)"
echo

echo -e "$(_c LIGHT_YELLOW "Network Info:")"
echo -e "  $(_c LIGHT_CYAN "ASN            ") $(extract_field asn)"
echo -e "  $(_c LIGHT_CYAN "Organization   ") $(extract_field org)"
echo

echo -e "$(_c LIGHT_YELLOW "Additional Info:")"
echo -e "  $(_c LIGHT_CYAN "Currency       ") $(extract_field currency_name) ($(extract_field currency))"
echo -e "  $(_c LIGHT_CYAN "Calling Code   ") $(extract_field country_calling_code)"
echo -e "  $(_c LIGHT_CYAN "Languages      ") $(extract_field languages)"
echo -e "  $(_c LIGHT_CYAN "Area           ") $(extract_field country_area) sq km"
echo -e "  $(_c LIGHT_CYAN "Population     ") $(extract_field country_population)"
echo

echo -e "$(_c LIGHT_BLUE "============================================================")"
echo -e "[$(_c LIGHT_BLUE "IT - IP Info")] $(_c LIGHT_GREEN "Information retrieved")" >&2
