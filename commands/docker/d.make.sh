if [[ -z "${1-}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Make")] $(_c LIGHT_YELLOW "Usage: d.mk <interpreter>")"
  exit
fi

if [[ ! -f "${EPX_HOME}/.templates/docker/dockerfile/${1}.template" ]]; then
  echo -e "[$(_c LIGHT_RED "Docker - Make")] $(_c LIGHT_YELLOW "Template for interpreter '${1}' not found.")"
  exit
fi

if [[ -f Dockerfile ]]; then
  echo -e "[$(_c LIGHT_RED "Docker - Make")] $(_c LIGHT_YELLOW "Dockerfile already exists. Please remove it before creating a new one.")"
  exit
fi

if ! cp -f "${EPX_HOME}/.templates/docker/dockerfile/${1}.template" Dockerfile >/dev/null 2>&1; then
  echo -e "[$(_c LIGHT_RED "Docker - Make")] $(_c LIGHT_YELLOW "Failed to copy template for interpreter '${1}'.")"
  exit
fi

echo -e "[$(_c LIGHT_BLUE "Docker - Make")] $(_c LIGHT_GREEN "Dockerfile created from template for interpreter '${1}'.")"
