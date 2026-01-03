_help() {
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")] Usage: $(_c LIGHT_YELLOW "it.hash <string|file> [hash-type]")"
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")] Hash a string or file using various algorithms"
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")]"
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")] Options:"
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")]"
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")]   it.hash sha512 'hello world'"
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")]   it.hash md5 /path/to/file"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "IT - Hash")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci openssl

hash_type="${1-}"
input="${2-}"

if [[ -z "$input" ]] || [[ -z "$hash_type" ]]; then
  _help
  exit 1
fi

_get_available_digests() {
  openssl list -digest-algorithms 2>/dev/null | grep -oP '^\s*\K[a-zA-Z0-9_-]+' | sort -u
}

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
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")] File mode: $(_c LIGHT_YELLOW "$input")"
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")] Computing $(_c LIGHT_YELLOW "$normalized_type") hash..." >&2

  result=$(openssl dgst -"$normalized_type" "$input" 2>&1)
  exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    echo "$result" | awk '{print $NF}'
    echo -e "[$(_c LIGHT_BLUE "IT - Hash")] $(_c LIGHT_GREEN "Hash computed successfully")" >&2
  else
    echo -e "[$(_c LIGHT_BLUE "IT - Hash")] $(_c LIGHT_RED "Error"): Unsupported hash type '$hash_type'" >&2
    echo -e "[$(_c LIGHT_BLUE "IT - Hash")] Available types: $(_c LIGHT_YELLOW "$(echo "$(_get_available_digests)" | head -10 | tr '\n' ', ' | sed 's/,$//')")" >&2
    exit 1
  fi
else
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")] String mode" >&2
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")] Computing $(_c LIGHT_YELLOW "$normalized_type") hash..." >&2

  result=$(echo -n "$input" | openssl dgst -"$normalized_type" 2>&1)
  exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    echo "$result" | awk '{print $NF}'
    echo -e "[$(_c LIGHT_BLUE "IT - Hash")] $(_c LIGHT_GREEN "Hash computed successfully")" >&2
  else
    echo -e "[$(_c LIGHT_BLUE "IT - Hash")] $(_c LIGHT_RED "Error"): Unsupported hash type '$hash_type'" >&2
    echo -e "[$(_c LIGHT_BLUE "IT - Hash")] Available types: $(_c LIGHT_YELLOW "$(echo "$(_get_available_digests)" | head -10 | tr '\n' ', ' | sed 's/,$//')")" >&2
    exit 1
  fi
fi
