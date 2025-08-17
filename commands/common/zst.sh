_cci time tar zstd

if [[ $# -eq 0 ]]; then
  echo -e "No input files"
  exit 1
fi

fbasename=$(basename -- "${@}")

time tar -I "zstd -T0 --ultra -22 -v --auto-threads=logical --long -M8192" -cf "${fbasename}.tar.zst" "${@}"
