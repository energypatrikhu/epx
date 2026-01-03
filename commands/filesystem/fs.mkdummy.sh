_cci dd

filename="${1-}"
size="${2-}"

if [[ -z "$filename" ]] || [[ -z "$size" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Make Dummy")] Usage: $(_c LIGHT_YELLOW "fs.createdummy <filename> <size>")"
  echo -e "[$(_c LIGHT_BLUE "Make Dummy")] Size format: $(_c LIGHT_YELLOW "1K, 1M, 1G, 1T")"
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
