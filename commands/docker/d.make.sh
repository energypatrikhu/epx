_help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - Make")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Make")] Usage: d.mk <interpreter>"
  echo -e "[$(_c LIGHT_BLUE "Docker - Make")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Make")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Make")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "Docker - Make")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Make")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Make")]   d.mk python"
  echo -e "[$(_c LIGHT_BLUE "Docker - Make")]   d.mk nodejs"
}

opt_help=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else
      echo -e "[$(_c LIGHT_BLUE "Docker - Make")] $(_c LIGHT_RED "Unknown option:") ${arg}"
      _help
      exit 1
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

if [[ -z "${1-}" ]]; then
  _help
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
