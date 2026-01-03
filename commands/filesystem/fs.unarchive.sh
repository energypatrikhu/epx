_cci tar

if [[ $# -eq 0 ]]; then
  echo -e "[$(_c LIGHT_BLUE "FS - Unarchive")] $(_c LIGHT_RED "Error"): No input archive files provided"
  echo -e "[$(_c LIGHT_BLUE "FS - Unarchive")] Usage: $(_c LIGHT_YELLOW "fs.unarchive <file> [file ...]")"
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
