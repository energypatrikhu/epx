_cci tar

if [[ $# -eq 0 ]]; then
  echo -e "[$(_c LIGHT_BLUE "FS - Archive")] $(_c LIGHT_RED "Error"): No input files or directories provided"
  echo -e "[$(_c LIGHT_BLUE "FS - Archive")] Usage: $(_c LIGHT_YELLOW "fs.archive <file|directory> [file|directory ...]")"
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
