_cci qrencode

ssid="${1-}"
password="${2-}"
security="${3:-wpa}"
output="${4-}"
hidden=""
eap_method=""
anonymous_identity=""
identity=""
phase2_method=""

escape_wifi_field() {
  local str="$1"
  str="${str//\\/\\\\}"
  str="${str//;/\\;}"
  str="${str//,/\\,}"
  str="${str//\"/\\\"}"
  str="${str//:/\\:}"
  echo "$str"
}

print_usage() {
  echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] Usage: $(_c LIGHT_YELLOW "it.qr-wifi [options]")"
  echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] Generate a WiFi QR code for easy network connection"
  echo -e ""
  echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] Options:"
  echo -e "  $(_c LIGHT_YELLOW "-s, --ssid <name>")         Network SSID (required)"
  echo -e "  $(_c LIGHT_YELLOW "-p, --password <pass>")     Password (required for secured networks)"
  echo -e "  $(_c LIGHT_YELLOW "-t, --type <type>")         Security type: wep, wpa (default), wpa3-only, wpa2-eap, nopass"
  echo -e "  $(_c LIGHT_YELLOW "-o, --output <file>")       Output file (if not specified, display in terminal)"
  echo -e "  $(_c LIGHT_YELLOW "-H, --hidden")              Network SSID is hidden"
  echo -e "  $(_c LIGHT_YELLOW "-e, --eap <method>")        (WPA2-EAP only) EAP method (TTLS, PWD, etc.)"
  echo -e "  $(_c LIGHT_YELLOW "-a, --anonymous <id>")      (WPA2-EAP only) Anonymous identity"
  echo -e "  $(_c LIGHT_YELLOW "-i, --identity <id>")       (WPA2-EAP only) Identity"
  echo -e "  $(_c LIGHT_YELLOW "--phase2 <method>")         (WPA2-EAP only) Phase 2 method (MSCHAPV2, etc.)"
  echo -e ""
  echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] Security Type Details:"
  echo -e "  $(_c LIGHT_YELLOW "wpa")          WPA/WPA2/WPA3 mixed mode (most compatible)"
  echo -e "  $(_c LIGHT_YELLOW "wpa3-only")    WPA3 only (requires WPA3-capable devices)"
  echo -e "  $(_c LIGHT_YELLOW "wep")          WEP encryption (legacy, not recommended)"
  echo -e "  $(_c LIGHT_YELLOW "wpa2-eap")     WPA2 with EAP authentication (enterprise)"
  echo -e "  $(_c LIGHT_YELLOW "nopass")       Open network (no password)"
  echo -e ""
  echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")]   it.qr-wifi -s 'MyNetwork' -p 'mypassword'"
  echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")]   it.qr-wifi -s 'MyNetwork' -p 'mypassword' -t wpa3-only -o wifi.png"
  echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")]   it.qr-wifi -s 'MyNetwork' -p 'mypass' -H -o hidden.png"
  echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")]   it.qr-wifi -s 'MyNetwork' -t wpa2-eap -e TTLS -i user@example.com"

}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--ssid)
      ssid="$2"
      shift 2
      ;;
    -p|--password)
      password="$2"
      shift 2
      ;;
    -t|--type)
      security="$2"
      shift 2
      ;;
    -o|--output)
      output="$2"
      shift 2
      ;;
    -H|--hidden)
      hidden="true"
      shift
      ;;
    -e|--eap)
      eap_method="$2"
      shift 2
      ;;
    -a|--anonymous)
      anonymous_identity="$2"
      shift 2
      ;;
    -i|--identity)
      identity="$2"
      shift 2
      ;;
    --phase2)
      phase2_method="$2"
      shift 2
      ;;
    *)
      echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Error"): Unknown option: $1" >&2
      print_usage
      exit 1
      ;;
  esac
done

if [[ -z "$ssid" ]]; then
  print_usage
  exit 1
fi

if [[ -z "$password" && "$security" != "nopass" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Error"): Password is required" >&2
  exit 1
fi

ssid_escaped=$(escape_wifi_field "$ssid")
password_escaped=$(escape_wifi_field "$password")

if [[ "$security" == "wpa3-only" ]]; then
  wifi_string="WIFI:T:WPA;R:1;S:$ssid_escaped;P:$password_escaped"
elif [[ "$security" == "nopass" ]]; then
  wifi_string="WIFI:T:nopass;S:$ssid_escaped"
else
  # Convert security type to uppercase for T field
  security_upper=$(echo "$security" | tr '[:lower:]' '[:upper:]')
  wifi_string="WIFI:T:$security_upper;S:$ssid_escaped;P:$password_escaped"
fi

if [[ -n "$hidden" ]]; then
  wifi_string="${wifi_string};H:true"
fi

if [[ "$security" == "wpa2-eap" ]]; then
  if [[ -n "$eap_method" ]]; then
    eap_escaped=$(escape_wifi_field "$eap_method")
    wifi_string="${wifi_string};E:$eap_escaped"
  fi
  if [[ -n "$anonymous_identity" ]]; then
    anon_escaped=$(escape_wifi_field "$anonymous_identity")
    wifi_string="${wifi_string};A:$anon_escaped"
  fi
  if [[ -n "$identity" ]]; then
    identity_escaped=$(escape_wifi_field "$identity")
    wifi_string="${wifi_string};I:$identity_escaped"
  fi
  if [[ -n "$phase2_method" ]]; then
    phase2_escaped=$(escape_wifi_field "$phase2_method")
    wifi_string="${wifi_string};PH2:$phase2_escaped"
  fi
fi

wifi_string="${wifi_string};;"

if ! command -v qrencode &>/dev/null; then
  echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Error"): qrencode not found, attempting to use Python..." >&2

  if command -v python3 &>/dev/null; then
    if [[ -n "$output" ]]; then
      echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] Generating WiFi QR code: $(_c LIGHT_YELLOW "$output")" >&2
      python3 << EOF
import qrcode
qr = qrcode.QRCode()
qr.add_data("$wifi_string")
qr.make()
qr.make_image().save("$output")
EOF

      if [[ $? -eq 0 ]]; then
        echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_GREEN "WiFi QR code saved to $output")" >&2
      else
        echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Error"): Failed to generate WiFi QR code" >&2
        exit 1
      fi
    else
      echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] Generating WiFi QR code in terminal..." >&2
      python3 << EOF
import qrcode
qr = qrcode.QRCode()
qr.add_data("$wifi_string")
qr.make()
qr.print_ascii()
EOF

      if [[ $? -eq 0 ]]; then
        echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_GREEN "WiFi QR code generated")" >&2
      else
        echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Error"): Failed to generate WiFi QR code" >&2
        exit 1
      fi
    fi
  else
    echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Error"): qrencode and Python3 not found" >&2
    exit 1
  fi
else
  if [[ -n "$output" ]]; then
    echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] Generating WiFi QR code: $(_c LIGHT_YELLOW "$output")" >&2
    qrencode -o "$output" "$wifi_string"

    if [[ $? -eq 0 ]]; then
      echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_GREEN "WiFi QR code saved to $output")" >&2
    else
      echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Error"): Failed to generate WiFi QR code" >&2
      exit 1
    fi
  else
    echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] Generating WiFi QR code in terminal..." >&2
    qrencode -t ANSI "$wifi_string"

    if [[ $? -eq 0 ]]; then
      echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_GREEN "WiFi QR code generated")" >&2
    else
      echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Error"): Failed to generate WiFi QR code" >&2
      exit 1
    fi
  fi
fi
