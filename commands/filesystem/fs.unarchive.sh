_help() {
  echo -e "[$(_c LIGHT_BLUE "FS - Unarchive")] Usage: $(_c LIGHT_YELLOW "fs.unarchive <file> [file ...]")"
  echo -e "[$(_c LIGHT_BLUE "FS - Unarchive")] Extract a tar archive from specified files"
  echo -e "[$(_c LIGHT_BLUE "FS - Unarchive")]"
  echo -e "[$(_c LIGHT_BLUE "FS - Unarchive")] Options:"
  echo -e "[$(_c LIGHT_BLUE "FS - Unarchive")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "FS - Unarchive")]"
  echo -e "[$(_c LIGHT_BLUE "FS - Unarchive")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "FS - Unarchive")]   fs.unarchive /path/to/archive.tar"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "FS - Unarchive")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci tar

if [[ $# -eq 0 ]]; then
  _help
  exit 1
fi

input_basename=$(basename -- "${@}")

echo -e "[$(_c LIGHT_BLUE "FS - Unarchive")] Extracting archive: $(_c LIGHT_YELLOW "${input_basename}")"
if tar -xvf "${input_basename}"; then
  echo -e "[$(_c LIGHT_BLUE "FS - Unarchive")] $(_c LIGHT_GREEN "Archive extracted successfully")"
else
  echo -e "[$(_c LIGHT_BLUE "FS - Unarchive")] $(_c LIGHT_RED "Failed to extract archive")"
  exit 1
fi
