_cci openssl

input="$1"
hash_type="${2:-sha256}"

_get_available_digests() {
  openssl list -digest-algorithms 2>/dev/null | grep -oP '^\s*\K[a-zA-Z0-9_-]+' | sort -u
}

_normalize_hash_type() {
  local type="$1"
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

if [[ -z "$input" ]]; then
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")] Usage: $(_c LIGHT_YELLOW "it.hash <string|file> [hash-type]")"
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")] Default type: $(_c LIGHT_YELLOW "sha256")"
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")] Common types: $(_c LIGHT_YELLOW "sha256, sha512, sha1, sha3, md5, blake2b, blake2s, rmd160")"
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")]   it.hash 'hello world'"
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")]   it.hash 'hello world' sha512"
  echo -e "[$(_c LIGHT_BLUE "IT - Hash")]   it.hash /path/to/file md5"
  exit 1
fi

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
