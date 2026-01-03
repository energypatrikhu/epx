_help() {
  echo -e "[$(_c LIGHT_BLUE "FS - ZST")] Usage: $(_c LIGHT_YELLOW "fs.zst <file|directory> [file|directory ...]")"
  echo -e "[$(_c LIGHT_BLUE "FS - ZST")] Create a zst-compressed tar archive from specified files or directories"
  echo -e "[$(_c LIGHT_BLUE "FS - ZST")]"
  echo -e "[$(_c LIGHT_BLUE "FS - ZST")] Options:"
  echo -e "[$(_c LIGHT_BLUE "FS - ZST")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "FS - ZST")]"
  echo -e "[$(_c LIGHT_BLUE "FS - ZST")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "FS - ZST")]   fs.zst /path/to/file1 /path/to/directory1"
  echo -e "[$(_c LIGHT_BLUE "FS - ZST")]   fs.zst /path/to/file1 /path/to/file2 /path/to/directory1 /path/to/directory2"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "FS - ZST")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg tar:tar zstd:zstd

if [[ $# -eq 0 ]]; then
  _help
  exit 1
fi

input_basename=$(basename -- "${@}")

echo -e "[$(_c LIGHT_BLUE "FS - ZST")] Creating archive: $(_c LIGHT_YELLOW "${input_basename}.tar")"
if tar -I "zstd -T0 --ultra -22 -v --auto-threads=logical --long -M8192" -cf "${input_basename}.tar.zst" "${@}"; then
  echo -e "[$(_c LIGHT_BLUE "FS - ZST")] $(_c LIGHT_GREEN "Archive created successfully")"
else
  echo -e "[$(_c LIGHT_BLUE "FS - ZST")] $(_c LIGHT_RED "Failed to create archive")"
  exit 1
fi
