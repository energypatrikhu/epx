# Finds and returns the path to a Docker Compose file in the specified directory.
#
# This function searches for either 'docker-compose.yaml' or 'docker-compose.yml'
# in the given directory path, returning the full path to the first match found.
# If neither file exists, it returns an empty string.
#
# Arguments:
#   ${1-} - The directory path to search (optional, defaults to current directory ".")
#
# Returns:
#   The full path to the compose file if found, empty string otherwise
#
# Example:
#   if check-compose-file "/path/to/project"; then
#     echo "Found compose file"
#   fi
check-compose-file() {
  local path="${1:-.}"

  if [[ -f "${path}/docker-compose.yml" ]]; then
    return 0
  elif [[ -f "${path}/docker-compose.yaml" ]]; then
    return 0
  elif [[ -f "${path}/compose.yml" ]]; then
    return 0
  elif [[ -f "${path}/compose.yaml" ]]; then
    return 0
  fi

  return 1
}
