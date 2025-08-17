_cci dockerif [[ -z "${1-}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Network")] $(_c LIGHT_YELLOW "Usage: d.net <... options>")"
  exit
fi

docker network "${@}"
