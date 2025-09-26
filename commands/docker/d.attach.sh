_cci docker

if [[ -z $* ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Attach")] $(_c LIGHT_YELLOW "Usage: d.attach <container>")"
  exit 1
fi

docker container attach --sig-proxy=false --detach-keys="ctrl-c" "${@}"
