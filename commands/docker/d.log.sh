_cci docker

if [[ -z $* ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Logs")] $(_c LIGHT_YELLOW "Usage: d.logs <container> [-a | --all]")"
  exit
fi

opt_all=false

for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*a(ll)?$ ]]; then
      opt_all=true
    else
      echo -e "[$(_c LIGHT_BLUE "Docker - Logs")] $(_c LIGHT_RED "Unknown option: ${arg}")"
      exit 1
    fi
  fi
done

if [[ "${opt_all}" == "true" ]]; then
  docker container logs -f "${1-}" --since "$(docker inspect "${1-}" | jq .[0].State.StartedAt | sed 's/"//g')"
  exit
fi

docker container logs -f "${@}"
