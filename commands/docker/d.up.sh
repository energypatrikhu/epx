help() {
  echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_YELLOW "Usage:") d.up $(_c LIGHT_YELLOW "[<options>] [container1, container2, ...]")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_YELLOW "Options:")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_YELLOW "  -a | --all") $(_c LIGHT_GREEN "Start all containers defined in the config file")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_YELLOW "  -h | --help") $(_c LIGHT_GREEN "Show this help message")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_YELLOW "  [container1, container2, ...]") $(_c LIGHT_GREEN "Start specific containers by name")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_YELLOW "  If no arguments are provided, it will start the compose file in the current directory")"
  echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_YELLOW "  If the config file is not found, it is necessary to create one at") ${EPX_HOME}/.config/docker.config"
}

opt_help=false
opt_all=false
opt_args=()
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    elif [[ "${arg}" =~ ^-*a(ll)?$ ]]; then
      opt_all=true
    else
      opt_args+=("${arg}")
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  help
  exit
fi

_cci_pkg docker:docker-ce-cli

source "${EPX_HOME}/helpers/check-compose-file.sh"
source "${EPX_HOME}/helpers/get-compose-filename.sh"

c_up()  {
  local c_file="${1}"

  docker compose --file "${c_file}" pull
  if [[ $? -ne 0 ]]; then
    echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_RED "Failed to pull images")"
  fi

  if grep -q "build:" "${c_file}"; then
    docker compose --file "${c_file}" build "${opt_args[@]}"
    if [[ $? -ne 0 ]]; then
      echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_RED "Failed to build images")"
    fi
  fi

  docker compose --file "${c_file}" up --pull never --detach --no-build --yes
  if [[ $? -ne 0 ]]; then
    echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_RED "Failed to start compose file") ${c_file}"
  fi
}

# if all option is provided, start all containers defined in the config file
if [[ "${opt_all}" == "true" ]]; then
  if [[ ! -f "${EPX_HOME}/.config/docker.config" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_RED "Config file not found, please create one at") ${EPX_HOME}/.config/docker.config"
    help
    exit
  fi

  . "${EPX_HOME}/.config/docker.config"

  c_count=0
  c_amount=0
  c_names=()
  for c_dir in "${CONTAINERS_DIR}"/*; do
    if [[ -d "${c_dir}" ]]; then
      c_amount=$((c_amount + 1))
      c_names+=("$(basename -- "${c_dir}")")
    fi
  done

  for c_name in "${c_names[@]}"; do
    c_dir="${CONTAINERS_DIR}/${c_name}"
    c_count=$((c_count + 1))

    if [[ $c_count -ne 1 ]]; then
      echo
    fi

    c_file="$(get_compose_filename "${c_dir}")"
    if [[ -z "${c_file}" ]]; then
      echo -e "[$(_c LIGHT_BLUE "Docker - Up")] [$(_c LIGHT_BLUE "${c_count}")/$(_c LIGHT_BLUE "${c_amount}")] compose file $(_c LIGHT_RED "not found in") ${c_dir} $(_c LIGHT_RED "skipping...")"
      continue
    fi

    if [[ -f "${c_dir}/.ignore-update" ]]; then
      echo -e "[$(_c LIGHT_BLUE "Docker - Up")] [$(_c LIGHT_BLUE "${c_count}")/$(_c LIGHT_BLUE "${c_amount}")] $(_c LIGHT_YELLOW "Skipping") ${c_name} $(_c LIGHT_YELLOW "as") .ignore-update $(_c LIGHT_YELLOW "file is present in") ${c_dir}"
      continue
    fi

    echo -e "[$(_c LIGHT_BLUE "Docker - Up")] [$(_c LIGHT_BLUE "${c_count}")/$(_c LIGHT_BLUE "${c_amount}")] $(_c LIGHT_BLUE "Starting") ${c_name}$(_c LIGHT_BLUE "...")"
    c_up "${c_file}"
  done
  exit
fi

# check if container name is provided
if [[ -n $* ]]; then
  if [[ ! -f "${EPX_HOME}/.config/docker.config" ]]; then
    echo -e "[$(_c LIGHT_BLUE "Docker - Up")] $(_c LIGHT_RED "Config file not found, please create one at") ${EPX_HOME}/.config/docker.config"
    help
    exit
  fi

  . "${EPX_HOME}/.config/docker.config"

  c_count=0
  c_amount=0
  container_names=()
  for arg in "$@"; do
    if [[ "${arg}" =~ ^-+ ]]; then
      continue
    fi
    c_amount=$((c_amount + 1))
    container_names+=("${arg}")
  done

  for c_name in "${container_names[@]}"; do
    c_dir="${CONTAINERS_DIR}/${c_name}"
    c_count=$((c_count + 1))

    if [[ $c_count -ne 1 ]]; then
      echo
    fi

    c_file="$(get_compose_filename "${c_dir}")"

    if [[ -z "${c_file}" ]]; then
      echo -e "[$(_c LIGHT_BLUE "Docker - Up")] [$(_c LIGHT_BLUE "${c_count}")/$(_c LIGHT_BLUE "${c_amount}")] compose file $(_c LIGHT_RED "not found in") ${c_dir} $(_c LIGHT_RED "skipping...")"
      continue
    fi

    echo -e "[$(_c LIGHT_BLUE "Docker - Up")] [$(_c LIGHT_BLUE "${c_count}")/$(_c LIGHT_BLUE "${c_amount}")] $(_c LIGHT_BLUE "Starting") ${c_name}..."
    c_up "${c_file}"
  done
  exit
fi

c_file="$(get_compose_filename)"

# if nothing is provided, just start compose file in current directory
if [[ -z "${c_file}" ]]; then
  echo -e "[$(_c LIGHT_BLUE "Docker - Up")] compose file $(_c LIGHT_RED "not found in current directory")"
  help
  exit
fi

echo -e "[$(_c LIGHT_BLUE "Docker - Up")] Starting compose file in current directory..."
c_up "${c_file}"
