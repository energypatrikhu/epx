_help() {
  echo -e "[$(_c LIGHT_BLUE "Make Dummy")] Usage: $(_c LIGHT_YELLOW "fs.createdummy <filename> <size>")"
  echo -e "[$(_c LIGHT_BLUE "Make Dummy")] Size format: $(_c LIGHT_YELLOW "1K, 1M, 1G, 1T")"
  echo -e "[$(_c LIGHT_BLUE "Make Dummy")] Create a dummy file of specified size"
  echo -e "[$(_c LIGHT_BLUE "Make Dummy")]"
  echo -e "[$(_c LIGHT_BLUE "Make Dummy")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Make Dummy")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "Make Dummy")]"
  echo -e "[$(_c LIGHT_BLUE "Make Dummy")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Make Dummy")]   fs.createdummy dummyfile.txt 10M"
  echo -e "[$(_c LIGHT_BLUE "Make Dummy")]   fs.createdummy test.bin 1G"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "Make Dummy")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci dd

filename="${1-}"
size="${2-}"

if [[ -z "$filename" ]] || [[ -z "$size" ]]; then
  _help
  exit 1
fi

if [[ "$filename" == *"/"* ]]; then
  echo -e "[$(_c LIGHT_BLUE "Make Dummy")] $(_c LIGHT_RED "Error"): Filename cannot contain path separators"
  exit 1
fi

if [[ -f "$filename" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Make Dummy")] $(_c LIGHT_RED "Error"): File '$(_c LIGHT_YELLOW "$filename")' already exists"
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "Make Dummy")] Creating dummy file: $(_c LIGHT_YELLOW "$filename") ($(_c LIGHT_YELLOW "$size"))"

if command -v fallocate &>/dev/null; then
  fallocate -l "$size" "$filename"
elif command -v truncate &>/dev/null; then
  truncate -s "$size" "$filename"
else
  dd if=/dev/zero of="$filename" bs=1 count="$size" 2>/dev/null || {
    echo -e "[$(_c LIGHT_BLUE "Make Dummy")] $(_c LIGHT_RED "Error"): Unable to parse size format"
    exit 1
  }
fi

if [[ $? -eq 0 ]] && [[ -f "$filename" ]]; then
  actual_size=$(du -h "$filename" | awk '{print $1}')
  echo -e "[$(_c LIGHT_BLUE "Make Dummy")] $(_c LIGHT_GREEN "Dummy file created successfully") ($actual_size)"
else
  echo -e "[$(_c LIGHT_BLUE "Make Dummy")] $(_c LIGHT_RED "Failed to create dummy file")"
  exit 1
fi
