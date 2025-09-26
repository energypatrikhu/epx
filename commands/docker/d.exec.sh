_cci docker

if [[ $# -lt 2 ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Exec")] $(_c LIGHT_YELLOW "Usage: d.exec <container> <command> [args]")"
  exit
fi

docker exec -it "${@}"
