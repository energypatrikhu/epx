_cci docker

if [[ -z "${1-}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Inspect")] $(_c LIGHT_YELLOW "Usage: d.inspect <container>")"
  exit
fi

docker inspect "${@}"
