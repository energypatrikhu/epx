get_compose_filename() {
  local path="${1:-.}"
  if [[ -f "${path}/docker-compose.yaml" ]]; then
    echo "${path}/docker-compose.yaml"
  elif [[ -f "${path}/docker-compose.yml" ]]; then
    echo "${path}/docker-compose.yml"
  else
    echo ""
  fi
}
