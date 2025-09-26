_cci python3 pm2

help(){
  echo -e "Usage: py.pm2 [script] [name]"
}

opt_help=false

for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "Python - PM2")] $(_c LIGHT_RED "Unknown option: ${arg}")"
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  help
  exit
fi

if [[ -n "${1-}" ]]; then
  filename="${1-}"
else
  filename="main.py"
fi

if [[ -n "${2-}" ]]; then
  project_name="${2-}"
else
  project_name=$(basename "${PWD}")
fi

# start Python script with PM2, for name use ${2-} if not available use ${PWD} last directory name
echo -e "[$(_c LIGHT_BLUE "Python - PM2")] Starting Python script with PM2"
pm2 start "${filename}" --interpreter="${PWD}/.venv/bin/python" --name="${project_name}" &>/dev/null

# save process list
echo -e "[$(_c LIGHT_BLUE "Python - PM2")] Saving process list"
pm2 save &>/dev/null
