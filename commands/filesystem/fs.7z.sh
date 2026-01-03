_cci 7z

directory="${1-}"
basename="$(basename "$directory")"

if [[ -z "$directory" ]]; then
  echo -e "[$(_c LIGHT_BLUE "7z Archive")] Usage: $(_c LIGHT_YELLOW "fs.7z <directory>")"
  exit 1
fi

if [[ ! -d "$directory" ]]; then
  echo -e "[$(_c LIGHT_BLUE "7z Archive")] $(_c LIGHT_RED "Error"): Directory '$(_c LIGHT_YELLOW "$directory")' does not exist"
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "7z Archive")] Creating 7z archive: $(_c LIGHT_YELLOW "${basename}.7z")"
7z a -t7z -ssp -m0=lzma2 -mx=9 -mfb=273 -md=768m -ms=on -mmt=on -mqs=on -bb3 -y "${basename}.7z" "${directory}"

if [[ $? -eq 0 ]]; then
  echo -e "[$(_c LIGHT_BLUE "7z Archive")] $(_c LIGHT_GREEN "7z archive created successfully")"
else
  echo -e "[$(_c LIGHT_BLUE "7z Archive")] $(_c LIGHT_RED "Failed to create 7z archive")"
  exit 1
fi
