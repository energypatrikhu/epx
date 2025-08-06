#!/bin/bash

echo "Building and Linking EPX commands to /usr/local/bin..."

mkdir -p "${EPX_HOME}/scripts" 2>/dev/null
/usr/bin/rm -rf "${EPX_HOME}/scripts/*" 2>/dev/null

_build_function() {
  local output_file="${EPX_HOME}/scripts/$(basename "${1}")"
  local temp_file=$(mktemp)

  while IFS= read -r line; do
    if [[ "${line}" =~ ^[[:space:]]*source[[:space:]]+([^\ ]+) ]]; then
      local src_file=$(sed 's/^[[:space:]]*source[[:space:]]\+//;s/[[:space:]].*//' <<<"${line}" | tr -d '"')
      if [[ "${src_file}" == "\${EPX_HOME}"* ]]; then
        src_file="${EPX_HOME}${src_file#"\${EPX_HOME}"}"
      fi

      local src_content=$(cat "${src_file}" 2>/dev/null)

      echo "# source: ${src_file}" >>"${temp_file}"
      echo "${src_content}" >>"${temp_file}"
      echo "" >>"${temp_file}"
    else
      echo "${line}" >>"${temp_file}"
    fi
  done <"${1}"

  if [[ -f "${output_file}" ]]; then
    /usr/bin/rm -f "${output_file}"
  fi

  if ! /usr/bin/mv "${temp_file}" "${output_file}"; then
    echo "Failed to build ${output_file}"
    return 1
  fi

  chmod a+x "${output_file}"

  /usr/bin/rm -f "${temp_file}"
}

_load_functions() {
  for element in "${1}"/*; do
    if [[ -d "${element}" ]]; then
      _load_functions "${element}"
      continue
    fi

    if [[ -f "${element}" ]] && [[ "${element}" == *.sh ]]; then
      file_name=$(basename "${element}")

      [[ "${file_name}" =~ ^_ ]] && continue

      if ! _build_function "${element}"; then
        echo "Failed to build ${element}"
        continue
      fi

      script_name="${file_name%.sh}"

      if ln -s "${EPX_HOME}/scripts/${file_name}" "/usr/local/bin/${script_name}" >/dev/null 2>&1; then
        chmod a+x "/usr/local/bin/${script_name}"
      fi
    fi
  done
}

_load_functions "${EPX_HOME}/commands"
_load_functions "${EPX_HOME}/scripts"
