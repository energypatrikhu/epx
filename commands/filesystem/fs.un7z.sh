_help() {
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Extract")] Usage: $(_c LIGHT_YELLOW "fs.un7z <archive.7z>")"
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Extract")] Extract a compressed 7z archive"
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Extract")]"
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Extract")] Options:"
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Extract")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Extract")]"
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Extract")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Extract")]   fs.un7z /path/to/archive.7z"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "FS - 7z Extract")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg 7z:7zip

archive="${1-}"

if [[ -z "$archive" ]]; then
  _help
  exit 1
fi

if [[ ! -f "$archive" ]]; then
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Extract")] $(_c LIGHT_RED "Error"): Archive '$(_c LIGHT_YELLOW "$archive")' does not exist"
  exit 1
fi

echo -e "[$(_c LIGHT_BLUE "FS - 7z Extract")] Extracting: $(_c LIGHT_YELLOW "$archive")"
7z x -mmt=on -bb3 -y "$archive"

if [[ $? -eq 0 ]]; then
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Extract")] $(_c LIGHT_GREEN "Archive extracted successfully")"
else
  echo -e "[$(_c LIGHT_BLUE "FS - 7z Extract")] $(_c LIGHT_RED "Failed to extract archive")"
  exit 1
fi
