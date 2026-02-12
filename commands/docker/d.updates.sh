_help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - Updates")] Usage: $(_c LIGHT_YELLOW "d.updates [container_name]")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Updates")] List updates for currently running containers"
  echo -e "[$(_c LIGHT_BLUE "Docker - Updates")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Updates")] Options:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Updates")]   -h, --help        Show this help message and exit"
  echo -e "[$(_c LIGHT_BLUE "Docker - Updates")]   [container_name]  Show updates for a specific container"
  echo -e "[$(_c LIGHT_BLUE "Docker - Updates")]"
  echo -e "[$(_c LIGHT_BLUE "Docker - Updates")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "Docker - Updates")]   d.updates"
  echo -e "[$(_c LIGHT_BLUE "Docker - Updates")]   d.updates my_container"
}

opt_help=false
container_name=""

for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    fi
  else
    container_name="${arg}"
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit 0
fi

_cci_pkg docker:docker-ce-cli

_check_container_updates() {
  local container="$1"
  local image_name
  local current_digest
  local latest_digest
  local manifest_verbose_output

  image_name=$(docker inspect "${container}" --format='{{.Config.Image}}' 2>/dev/null)

  if [[ -z "${image_name}" ]]; then
    return 0
  fi

  current_digest=$(docker image inspect "${image_name}" 2>/dev/null | jq -r '.[0].Id // empty' | sed 's/sha256://')

  if [[ -z "${current_digest}" ]]; then
    return 0
  fi

  echo -e "[$(_c LIGHT_BLUE "Docker - Updates")] Checking updates for $(_c LIGHT_CYAN "${container}") (Image: $(_c LIGHT_YELLOW "${image_name}"))..."

  manifest_verbose_output=$(docker manifest inspect --verbose "${image_name}" 2>/dev/null || true)

  if [[ -z "${manifest_verbose_output}" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Docker - Updates")]   $(_c LIGHT_YELLOW "Unable to retrieve manifest for") $(_c LIGHT_CYAN "${image_name}")"
    return 0
  fi

  latest_digest=$(printf "%s" "${manifest_verbose_output}" | jq -r '.OCIManifest.config.digest // empty' 2>/dev/null | sed 's/sha256://')

  if [[ -z "${latest_digest}" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Docker - Updates")]   $(_c LIGHT_YELLOW "Unable to retrieve latest digest for") $(_c LIGHT_CYAN "${image_name}")"
    return 0
  fi

  if [[ "${current_digest}" == "${latest_digest}" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Docker - Updates")]   $(_c GREEN "No updates available")"
  else
    echo -e "[$(_c LIGHT_BLUE "Docker - Updates")]   $(_c LIGHT_YELLOW "Update available for") $(_c LIGHT_CYAN "${image_name}")"
    echo -e "[$(_c LIGHT_BLUE "Docker - Updates")]   $(_c LIGHT_YELLOW "Current:") $(_c LIGHT_GRAY "${current_digest:0:19}...")"
    echo -e "[$(_c LIGHT_BLUE "Docker - Updates")]   $(_c LIGHT_YELLOW "Latest:") $(_c LIGHT_GRAY "${latest_digest:0:19}...")"
  fi

  return 0
}

if [[ -n "${container_name}" ]]; then
  _check_container_updates "${container_name}"
else
  running_containers=$(docker ps --format '{{.Names}}' 2>/dev/null)

  if [[ -z "${running_containers}" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Docker - Updates")] $(_c LIGHT_YELLOW "No running containers found")"
  else
    first=true
    while IFS= read -r container; do
      if [[ -n "${container}" ]]; then
        if [[ "${first}" == "true" ]]; then
          first=false
        else
          echo
        fi
        _check_container_updates "${container}"
      fi
    done <<< "${running_containers}"
  fi
fi

exit 0
