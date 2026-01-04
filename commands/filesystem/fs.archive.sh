_help() {
  echo -e "[$(_c LIGHT_BLUE "FS - Archive")] Usage: $(_c LIGHT_YELLOW "fs.archive <file|directory> [file|directory ...]")"
  echo -e "[$(_c LIGHT_BLUE "FS - Archive")] Create a tar archive from specified files or directories"
  echo -e "[$(_c LIGHT_BLUE "FS - Archive")]"
  echo -e "[$(_c LIGHT_BLUE "FS - Archive")] Options:"
  echo -e "[$(_c LIGHT_BLUE "FS - Archive")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "FS - Archive")]"
  echo -e "[$(_c LIGHT_BLUE "FS - Archive")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "FS - Archive")]   fs.archive /path/to/file1 /path/to/directory1"
  echo -e "[$(_c LIGHT_BLUE "FS - Archive")]   fs.archive /path/to/file1 /path/to/file2 /path/to/directory1 /path/to/directory2"
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

_cci_pkg tar:tar

if [[ $# -eq 0 ]]; then
  _help
  exit 1
fi

file_basename=$(basename -- "${@}")

echo -e "[$(_c LIGHT_BLUE "FS - Archive")] Creating archive: $(_c LIGHT_YELLOW "${file_basename}.tar")"
if tar -cvf "${file_basename}.tar" "${@}"; then
  echo -e "[$(_c LIGHT_BLUE "FS - Archive")] $(_c LIGHT_GREEN "Archive created successfully")"
else
  echo -e "[$(_c LIGHT_BLUE "FS - Archive")] $(_c LIGHT_RED "Failed to create archive")"
  exit 1
fi
