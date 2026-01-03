_it_commands=(
  "b64:Encode or decode Base64 strings"
  "rnd-string:Generate random strings of specified length"
  "rnd-number:Generate random numbers within a specified range"
  "rnd-port:Find an available random port on the system"
  "hash:Generate hashes for a given string or file"
  "hmac:Generate HMAC hashes for a given string or file using a secret key"
  "uuid:Generate UUIDs of specified version"
  "qr:Generate QR codes from text or URLs"
  "barcode:Generate barcodes from text or numbers"
  "timestamp:Convert between human-readable dates and Unix timestamps"
  "timezone:Display current time in different time zones"
  "ipinfo:Retrieve information about an IP address"
  "useragent:Parse and display information from a user-agent string"
  "urlencode:URL encode or decode strings"
  "htmlencode:HTML encode or decode strings"
  "regex-test:Test if a string matches a given regular expression"
  "regex-extract:Extract substrings from a string using a regular expression"
)

_it_hash_types=(
  "sha256"
  "sha512"
  "sha1"
  "sha3"
  "md5"
  "blake2b"
  "blake2s"
  "rmd160"
  "sha224"
  "sha384"
)

_it_uuid_versions=(
  "1:Time-based UUID"
  "3:MD5 namespace-based UUID"
  "4:Random UUID"
  "5:SHA-1 namespace-based UUID"
)

_it_encode_modes=(
  "encode"
  "decode"
)

_complete_it_b64() {
  COMPREPLY=($(compgen -W "encode decode" -- "${COMP_WORDS[-1]}"))
}

_complete_it_hash() {
  if [[ ${#COMP_WORDS[@]} -eq 2 ]]; then
    COMPREPLY=()
  elif [[ ${#COMP_WORDS[@]} -eq 3 ]]; then
    COMPREPLY=($(compgen -W "${_it_hash_types[*]}" -- "${COMP_WORDS[-1]}"))
  fi
}

_complete_it_hmac() {
  if [[ ${#COMP_WORDS[@]} -eq 4 ]]; then
    COMPREPLY=($(compgen -W "${_it_hash_types[*]}" -- "${COMP_WORDS[-1]}"))
  fi
}

_complete_it_uuid() {
  if [[ ${#COMP_WORDS[@]} -eq 2 ]]; then
    COMPREPLY=($(compgen -W "1 3 4 5" -- "${COMP_WORDS[-1]}"))
  fi
}

_complete_it_urlencode() {
  COMPREPLY=($(compgen -W "encode decode" -- "${COMP_WORDS[-1]}"))
}

_complete_it_htmlencode() {
  COMPREPLY=($(compgen -W "encode decode" -- "${COMP_WORDS[-1]}"))
}

_complete_it_rnd_number() {
  if [[ ${#COMP_WORDS[@]} -eq 2 ]]; then
    COMPREPLY=()
  elif [[ ${#COMP_WORDS[@]} -eq 3 ]]; then
    COMPREPLY=()
  fi
}

local current_command="${COMP_WORDS[0]##*/}"
local cmd_name="${current_command#it.}"

case "$cmd_name" in
  b64)
    _complete_it_b64
    ;;
  hash)
    _complete_it_hash
    ;;
  hmac)
    _complete_it_hmac
    ;;
  uuid)
    _complete_it_uuid
    ;;
  urlencode)
    _complete_it_urlencode
    ;;
  htmlencode)
    _complete_it_htmlencode
    ;;
  rnd-number)
    _complete_it_rnd_number
    ;;
esac
