_cci time tar

if [[ $# -eq 0 ]]; then
  echo -e "No input files"
  exit 1
fi

fbasename=$(basename -- "${@}")

time tar -xvf "${fbasename}"
