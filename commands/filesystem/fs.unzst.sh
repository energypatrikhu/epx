_help() {
  echo -e "[$(_c LIGHT_BLUE "FS - UNZST")] Usage: $(_c LIGHT_YELLOW "fs.unzst <file> [file ...]")"
  echo -e "[$(_c LIGHT_BLUE "FS - UNZST")] Extract a zst-compressed tar archive"
  echo -e "[$(_c LIGHT_BLUE "FS - UNZST")]"
  echo -e "[$(_c LIGHT_BLUE "FS - UNZST")] Options:"
  echo -e "[$(_c LIGHT_BLUE "FS - UNZST")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "FS - UNZST")]"
  echo -e "[$(_c LIGHT_BLUE "FS - UNZST")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "FS - UNZST")]   fs.unzst /path/to/archive.tar.zst"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "FS - UNZST")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci tar zstd

if [[ $# -eq 0 ]]; then
  _help
  exit 1
fi

input_basename=$(basename -- "${@}")

echo -e "[$(_c LIGHT_BLUE "FS - UNZST")] Extracting archive: $(_c LIGHT_YELLOW "${input_basename}")"
if tar --use-compress-program=unzstd -xvf "${input_basename}"; then
  echo -e "[$(_c LIGHT_BLUE "FS - UNZST")] $(_c LIGHT_GREEN "Archive extracted successfully")"
else
  echo -e "[$(_c LIGHT_BLUE "FS - UNZST")] $(_c LIGHT_RED "Failed to extract archive")"
  exit 1
fi
