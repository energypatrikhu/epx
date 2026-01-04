_help() {
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Archive")] Usage: $(_c LIGHT_YELLOW "fs.7z <directory>")"
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Archive")] Create a compressed 7z archive from the specified directory"
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Archive")]"
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Archive")] Options:"
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Archive")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Archive")]"
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Archive")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Archive")]   fs.7z /path/to/directory"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg 7z:7zip

directory="${1-}"
basename="$(basename "$directory")"

if [[ -z "$directory" ]]; then
  _help
  exit 1
fi

if [[ ! -d "$directory" ]]; then
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Archive")] $(_c LIGHT_RED "Error"): Directory '$(_c LIGHT_YELLOW "$directory")' does not exist"
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "FS - 7z Archive")] Creating 7z archive: $(_c LIGHT_YELLOW "${basename}.7z")"
7z a -t7z -ssp -m0=lzma2 -mx=9 -mfb=273 -md=768m -ms=on -mmt=on -mqs=on -bb3 -y "${basename}.7z" "${directory}"

if [[ $? -eq 0 ]]; then
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Archive")] $(_c LIGHT_GREEN "7z archive created successfully")"
else
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Archive")] $(_c LIGHT_RED "Failed to create 7z archive")"
  exit 1
fi
