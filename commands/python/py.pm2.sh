_cci python3 pm2# help message
if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
  echo -e "Usage: py.pm2 [script] [name]"
  exit 0
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
