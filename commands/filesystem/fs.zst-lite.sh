_cci tar zstd

if [[ $# -eq 0 ]]; then
  echo -e "[$(_c LIGHT_BLUE "FS - ZST LITE")] $(_c LIGHT_RED "Error"): No input files or directories provided"
  echo -e "[$(_c LIGHT_BLUE "FS - ZST LITE")] Usage: $(_c LIGHT_YELLOW "fs.zst-lite <file|directory> [file|directory ...]")"
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
