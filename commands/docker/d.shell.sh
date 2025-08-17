_cci dockerif [[ -z "${1-}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Shell")] $(_c LIGHT_YELLOW "Usage: d.shell <container>")"
  exit
fi

for shell in bash sh; do
  if docker exec -it ${1-} "${shell}" 2>/dev/null; then
    exit
  fi
done
echo -e "[$(_c LIGHT_BLUE "Docker - Shell")] $(_c LIGHT_RED "Error:") $(_c LIGHT_YELLOW "No suitable shell found in container ${1}")"
