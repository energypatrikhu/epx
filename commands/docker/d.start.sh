_cci docker

if [[ -z $* ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Start")] $(_c LIGHT_YELLOW "Usage: d.start <all / container>")"
  exit
fi

if [[ "${1-}" == "all" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Start")] $(_c LIGHT_GREEN "Starting all containers...")"
  docker container start $(docker ps -aq) >/dev/null 2>&1
  echo -e "[$(_c LIGHT_BLUE "Docker - Start")] $(_c LIGHT_GREEN "All containers started")"
else
  if [[ $# -eq 1 ]]; then
    container_text="Container"
  else
    container_text="Containers"
  fi

  read -ra arr <<<$*
  containers=""
  for i in "${arr[@]}"; do
    i=$(echo "${i}" | xargs) # trim spaces
    if [[ -n "${containers}" ]]; then
      containers+=", "
    fi
    containers+="$(_c LIGHT_BLUE "${i}")"
  done

  echo -e "[$(_c LIGHT_BLUE "Docker - Start")] ${container_text} $(_c LIGHT_BLUE "${containers}") $(_c LIGHT_GREEN "starting...")"
  docker container start "${@}" >/dev/null 2>&1
  echo -e "[$(_c LIGHT_BLUE "Docker - Start")] ${container_text} $(_c LIGHT_BLUE "${containers}") $(_c LIGHT_GREEN "started")"
fi
