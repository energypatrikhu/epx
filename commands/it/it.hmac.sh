_help() {
  echo -e "[$(_c LIGHT_BLUE "IT - HMAC")] Usage: $(_c LIGHT_YELLOW "it.hmac <string|file> <key> [hash-type]")"
  echo -e "[$(_c LIGHT_BLUE "IT - HMAC")] Default hash type: $(_c LIGHT_YELLOW "sha256")"
  echo -e "[$(_c LIGHT_BLUE "IT - HMAC")] Common types: $(_c LIGHT_YELLOW "sha256, sha512, sha1, sha3, md5")"
  echo -e "[$(_c LIGHT_BLUE "IT - HMAC")]"
  echo -e "[$(_c LIGHT_BLUE "IT - HMAC")] Options:"
  echo -e "[$(_c LIGHT_BLUE "IT - HMAC")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "IT - HMAC")]"
  echo -e "[$(_c LIGHT_BLUE "IT - HMAC")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - HMAC")]   it.hmac sha512 'hello world' 'my-secret'"
  echo -e "[$(_c LIGHT_BLUE "IT - HMAC")]   it.hmac md5 /path/to/file 'my-secret'"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "IT - HMAC")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg openssl:openssl

hash_type="${1-}"
input="${2-}"
key="${3-}"

if [[ -z "$hash_type" ]] || [[ -z "$input" ]] || [[ -z "$key" ]]; then
  _help
  exit 1
fi

_normalize_hash_type() {
  local type="${1-}"
  case "$type" in
    sha256|256) echo "sha256" ;;
    sha512|512) echo "sha512" ;;
    sha1|1) echo "sha1" ;;
    sha3|sha3-256) echo "sha3-256" ;;
    sha3-512) echo "sha3-512" ;;
    md5) echo "md5" ;;
    blake2b) echo "blake2b512" ;;
    blake2s) echo "blake2s256" ;;
    rmd160|ripemd160) echo "rmd160" ;;
    sha224) echo "sha224" ;;
    sha384) echo "sha384" ;;
    *) echo "$type" ;;
  esac
}

normalized_type=$(_normalize_hash_type "$hash_type")

if [[ -f "$input" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - HMAC")] File mode: $(_c LIGHT_YELLOW "$input")"
  echo -e "[$(_c LIGHT_BLUE "IT - HMAC")] Computing $(_c LIGHT_YELLOW "$normalized_type") HMAC..." >&2

  result=$(openssl dgst -"$normalized_type" -mac HMAC -macopt key:"$key" "$input" 2>&1)
  exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    echo "$result" | awk '{print $NF}'
    echo -e "[$(_c LIGHT_BLUE "IT - HMAC")] $(_c LIGHT_GREEN "HMAC computed successfully")" >&2
  else
    echo -e "[$(_c LIGHT_BLUE "IT - HMAC")] $(_c LIGHT_RED "Error"): Failed to compute HMAC with type '$hash_type'" >&2
    exit 1
  fi
else
  echo -e "[$(_c LIGHT_BLUE "IT - HMAC")] String mode" >&2
  echo -e "[$(_c LIGHT_BLUE "IT - HMAC")] Computing $(_c LIGHT_YELLOW "$normalized_type") HMAC..." >&2

  result=$(echo -n "$input" | openssl dgst -"$normalized_type" -mac HMAC -macopt key:"$key" 2>&1)
  exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    echo "$result" | awk '{print $NF}'
    echo -e "[$(_c LIGHT_BLUE "IT - HMAC")] $(_c LIGHT_GREEN "HMAC computed successfully")" >&2
  else
    echo -e "[$(_c LIGHT_BLUE "IT - HMAC")] $(_c LIGHT_RED "Error"): Failed to compute HMAC with type '$hash_type'" >&2
    exit 1
  fi
fi
