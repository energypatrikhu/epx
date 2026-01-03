_cci 7z

archive="${1-}"

if [[ -z "$archive" ]]; then
  echo -e "[$(_c LIGHT_BLUE "7z Extract")] Usage: $(_c LIGHT_YELLOW "fs.un7z <archive.7z>")"
  exit 1
fi

if [[ ! -f "$archive" ]]; then
  echo -e "[$(_c LIGHT_BLUE "7z Extract")] $(_c LIGHT_RED "Error"): Archive '$(_c LIGHT_YELLOW "$archive")' does not exist"
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "7z Extract")] Extracting: $(_c LIGHT_YELLOW "$archive")"
7z x -mmt=on -bb3 -y "$archive"

if [[ $? -eq 0 ]]; then
  echo -e "[$(_c LIGHT_BLUE "7z Extract")] $(_c LIGHT_GREEN "Archive extracted successfully")"
else
  echo -e "[$(_c LIGHT_BLUE "7z Extract")] $(_c LIGHT_RED "Failed to extract archive")"
  exit 1
fi
