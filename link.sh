#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
  set -o xtrace
fi

echo "Building and Linking EPX commands to /usr/local/bin..."

mkdir -p "${EPX_HOME}/scripts" 2>/dev/null
rm -rf "${EPX_HOME}/scripts/"* 2>/dev/null

GLOBAL_INCLUDES=(
  "${EPX_HOME}/helpers/header.sh"
  "${EPX_HOME}/helpers/shared.sh"
  "${EPX_HOME}/helpers/colors.sh"
  "${EPX_HOME}/helpers/colorize.sh"
  "${EPX_HOME}/helpers/check-command-installed.sh"
)

# Inject global includes at the top of each script
_build_function() {
  local output_file="${EPX_HOME}/scripts/$(basename "${1-}")"
  local include_headers="${2-}"

  local temp_file
  temp_file=$(mktemp)

  if [[ "${include_headers}" == "true" ]]; then
    for include in "${GLOBAL_INCLUDES[@]}"; do
      if [[ -f "${include}" ]]; then
        cat "${include}" >>"${temp_file}"
        echo "" >>"${temp_file}"
      fi
    done
  fi
  # Write global includes
  for include in "${GLOBAL_INCLUDES[@]}"; do
    if [[ -f "${include}" ]]; then
      cat "${include}" >>"${temp_file}"
      echo "" >>"${temp_file}"
    fi
  done

  while IFS= read -r line; do
    if [[ "${line}" =~ ^[[:space:]]*source[[:space:]]+([^\ ]+\.sh) ]]; then
      local src_file
      src_file=$(sed 's/^[[:space:]]*source[[:space:]]\+//;s/[[:space:]].*//' <<<"${line}" | tr -d '"')

      if [[ "${src_file}" == "\${EPX_HOME}"* ]]; then
        src_file="${EPX_HOME}${src_file#"\${EPX_HOME}"}"
      fi

      local src_content
      src_content=$(cat "${src_file}" 2>/dev/null)

      echo "${src_content}" >>"${temp_file}"
      echo "" >>"${temp_file}"
    else
      echo "${line}" >>"${temp_file}"
    fi
  done <${1-}

  if [[ -f "${output_file}" ]]; then
    rm -f "${output_file}"
  fi

  if ! /usr/bin/mv "${temp_file}" "${output_file}"; then
    echo "Failed to build ${output_file}"
    return 1
  fi

  chmod a+x "${output_file}"

  rm -f "${temp_file}"
}

_load_functions() {
  local element
  for element in "${1-}"/*; do
    if [[ -d "${element}" ]]; then
      _load_functions "${element}"
      continue
    fi

    if [[ -f "${element}" ]] && [[ "${element}" == *.sh ]]; then
      local file_name
      file_name=$(basename "${element}")

      [[ "${file_name}" =~ ^_ ]] && continue

      if ! _build_function "${element}"; then
        echo "Failed to build ${element}"
        continue
      fi

      local script_name="${file_name%.sh}"

      if ln -s "${EPX_HOME}/scripts/${file_name}" "/usr/local/bin/${script_name}" >/dev/null 2>&1; then
        chmod a+x "/usr/local/bin/${script_name}"
      fi
    fi
  done
}

_load_functions "${EPX_HOME}/commands" "true"
_load_functions "${EPX_HOME}/scripts" "false"

# Find and remove broken symlinks in /usr/local/bin that point to /usr/local/epx/scripts
find /usr/local/bin -maxdepth 1 -type l -exec bash -c '
  for link; do
    target=$(readlink "${link}")
    if [[ "${target#${EPX_HOME}/scripts/}" != "${target}" ]]; then
      if [[ ! -e "${target}" ]]; then
        echo "Removing broken symlink: ${link} -> ${target}"
        rm "${link}"
      fi
    fi
  done
' bash {} +
