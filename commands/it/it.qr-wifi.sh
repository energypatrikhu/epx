_help() {
  echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] Usage: $(_c LIGHT_YELLOW "it.qr-wifi [options]")"
  echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] Generate a WiFi QR code for easy network connection"
  echo -e ""
  echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] Options:"
  echo -e "  $(_c LIGHT_YELLOW "-h, --help")                Show this help message"
  echo -e "  $(_c LIGHT_YELLOW "-s, --ssid <name>")         Network SSID (required)"
  echo -e "  $(_c LIGHT_YELLOW "-p, --password <pass>")     Password (required for secured networks)"
  echo -e "  $(_c LIGHT_YELLOW "-t, --type <type>")         Security type: wep, wpa (default), wpa2-wpa3, wpa3-only, wpa2-eap, nopass"
  echo -e "  $(_c LIGHT_YELLOW "-o, --output <file>")       Output file (if not specified, display in terminal)"
  echo -e "  $(_c LIGHT_YELLOW "-H, --hidden")              Network SSID is hidden"
  echo -e "  $(_c LIGHT_YELLOW "-d, --debug")               Print WiFi string for debugging"
  echo -e "  $(_c LIGHT_YELLOW "-e, --eap <method>")        (WPA2-EAP only) EAP method (TTLS, PWD, etc.)"
  echo -e "  $(_c LIGHT_YELLOW "-a, --anonymous <id>")      (WPA2-EAP only) Anonymous identity"
  echo -e "  $(_c LIGHT_YELLOW "-i, --identity <id>")       (WPA2-EAP only) Identity"
  echo -e "  $(_c LIGHT_YELLOW "--phase2 <method>")         (WPA2-EAP only) Phase 2 method (MSCHAPV2, etc.)"
  echo -e ""
  echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] Security Type Details:"
  echo -e "  $(_c LIGHT_YELLOW "wpa")          WPA/WPA2/WPA3 mixed mode (most compatible)"
  echo -e "  $(_c LIGHT_YELLOW "wpa2-wpa3")    WPA2/WPA3 mixed mode"
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

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg qrencode:qrencode

ssid=""
password=""
security="wpa"
output=""
hidden=""
debug=""
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

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--ssid)
      if [[ -z "$2" ]]; then
        echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Error"): --ssid requires an argument" >&2
        exit 1
      fi
      ssid="$2"
      shift 2
      ;;
    -p|--password)
      if [[ -z "$2" ]]; then
        echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Error"): --password requires an argument" >&2
        exit 1
      fi
      password="$2"
      shift 2
      ;;
    -t|--type)
      if [[ -z "$2" ]]; then
        echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Error"): --type requires an argument" >&2
        exit 1
      fi
      security="$2"
      shift 2
      ;;
    -o|--output)
      if [[ -z "$2" ]]; then
        echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Error"): --output requires an argument" >&2
        exit 1
      fi
      output="$2"
      shift 2
      ;;
    -H|--hidden)
      hidden="true"
      shift
      ;;
    -d|--debug)
      debug="true"
      shift
      ;;
    -e|--eap)
      if [[ -z "$2" ]]; then
        echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Error"): --eap requires an argument" >&2
        exit 1
      fi
      eap_method="$2"
      shift 2
      ;;
    -a|--anonymous)
      if [[ -z "$2" ]]; then
        echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Error"): --anonymous requires an argument" >&2
        exit 1
      fi
      anonymous_identity="$2"
      shift 2
      ;;
    -i|--identity)
      if [[ -z "$2" ]]; then
        echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Error"): --identity requires an argument" >&2
        exit 1
      fi
      identity="$2"
      shift 2
      ;;
    --phase2)
      if [[ -z "$2" ]]; then
        echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Error"): --phase2 requires an argument" >&2
        exit 1
      fi
      phase2_method="$2"
      shift 2
      ;;
    *)
      echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Error"): Unknown option: $1" >&2
      _help
      exit 1
      ;;
  esac
done

if [[ -z "$ssid" ]]; then
  _help
  exit 1
fi

if [[ -z "$password" && "$security" != "nopass" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_RED "Error"): Password is required" >&2
  exit 1
fi

ssid_escaped=$(escape_wifi_field "$ssid")
password_escaped=$(escape_wifi_field "$password")

if [[ "$security" == "wpa3-only" ]]; then
  wifi_string="WIFI:S:$ssid_escaped;T:WPA3;P:$password_escaped;R:1;;"
elif [[ "$security" == "wpa2-wpa3" ]]; then
  wifi_string="WIFI:S:$ssid_escaped;T:WPA3;P:$password_escaped;;"
elif [[ "$security" == "nopass" ]]; then
  wifi_string="WIFI:S:$ssid_escaped;T:nopass;;"
elif [[ "$security" == "wpa" ]]; then
  wifi_string="WIFI:S:$ssid_escaped;T:WPA;P:$password_escaped;;"
else
  security_upper=$(echo "$security" | tr '[:lower:]' '[:upper:]')
  wifi_string="WIFI:S:$ssid_escaped;T:$security_upper;P:$password_escaped;;"
fi

if [[ -n "$hidden" ]]; then
  wifi_string="${wifi_string%;;};H:true;;"
fi

if [[ "$security" == "wpa2-eap" ]]; then
  if [[ -n "$eap_method" ]]; then
    eap_escaped=$(escape_wifi_field "$eap_method")
    wifi_string="${wifi_string%;;};E:$eap_escaped;;"
  fi
  if [[ -n "$anonymous_identity" ]]; then
    anon_escaped=$(escape_wifi_field "$anonymous_identity")
    wifi_string="${wifi_string%;;};A:$anon_escaped;;"
  fi
  if [[ -n "$identity" ]]; then
    identity_escaped=$(escape_wifi_field "$identity")
    wifi_string="${wifi_string%;;};I:$identity_escaped;;"
  fi
  if [[ -n "$phase2_method" ]]; then
    phase2_escaped=$(escape_wifi_field "$phase2_method")
    wifi_string="${wifi_string%;;};PH2:$phase2_escaped;;"
  fi
fi

if [[ -n "$debug" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - WiFi QR")] $(_c LIGHT_YELLOW "WiFi String"): $wifi_string" >&2
fi

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
