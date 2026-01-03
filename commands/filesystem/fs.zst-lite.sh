_help() {
  echo -e "[$(_c LIGHT_BLUE "FS - ZST LITE")] Usage: $(_c LIGHT_YELLOW "fs.zst-lite <file|directory> [file|directory ...]")"
  echo -e "[$(_c LIGHT_BLUE "FS - ZST LITE")] Create a zst-compressed tar archive from specified files or directories"
  echo -e "[$(_c LIGHT_BLUE "FS - ZST LITE")]"
  echo -e "[$(_c LIGHT_BLUE "FS - ZST LITE")] Options:"
  echo -e "[$(_c LIGHT_BLUE "FS - ZST LITE")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "FS - ZST LITE")]"
  echo -e "[$(_c LIGHT_BLUE "FS - ZST LITE")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "FS - ZST LITE")]   fs.zst-lite /path/to/file1 /path/to/directory1"
  echo -e "[$(_c LIGHT_BLUE "FS - ZST LITE")]   fs.zst-lite /path/to/file1 /path/to/file2 /path/to/directory1 /path/to/directory2"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "FS - ZST LITE")] $(_c LIGHT_RED "Unknown option:") ${arg}"
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

echo -e "[$(_c LIGHT_BLUE "FS - ZST LITE")] Creating archive: $(_c LIGHT_YELLOW "${input_basename}.tar")"
if tar -I "zstd -T0 -19 -v --auto-threads=logical --long" -cf "${input_basename}.tar.zst" "${@}"; then
  echo -e "[$(_c LIGHT_BLUE "FS - ZST LITE")] $(_c LIGHT_GREEN "Archive created successfully")"
else
  echo -e "[$(_c LIGHT_BLUE "FS - ZST LITE")] $(_c LIGHT_RED "Failed to create archive")"
  exit 1
fi
