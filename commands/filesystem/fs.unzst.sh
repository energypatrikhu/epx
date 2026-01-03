_cci tar zstd

if [[ $# -eq 0 ]]; then
  echo -e "[$(_c LIGHT_BLUE "FS - UNZST")] $(_c LIGHT_RED "Error"): No input archive files provided"
  echo -e "[$(_c LIGHT_BLUE "FS - UNZST")] Usage: $(_c LIGHT_YELLOW "fs.unzst <file> [file ...]")"
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
