_cci time tar zstd

if [[ $# -eq 0 ]]; then
  echo -e "No input files"
  exit 1
fi

fbasename=$(basename -- "${@}")

time tar --use-compress-program=unzstd -xvf "${fbasename}"
