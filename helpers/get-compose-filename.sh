# Finds and returns the path to a Docker Compose file in the specified directory.
#
# This function searches for either 'docker-compose.yaml' or 'docker-compose.yml'
# in the given directory path, returning the full path to the first match found.
# If neither file exists, it returns an empty string.
#
# Arguments:
#   $1 - The directory path to search (optional, defaults to current directory ".")
#
# Returns:
#   The full path to the compose file if found, empty string otherwise
#
# Example:
#   compose_file=$(get_compose_filename "/path/to/project")
#   if [[ -n "$compose_file" ]]; then
#     echo "Found compose file: $compose_file"
#   fi
get_compose_filename() {
  local path="${1:-.}"
  if [[ -f "${path}/docker-compose.yaml" ]]; then
    echo "${path}/docker-compose.yaml"
  elif [[ -f "${path}/docker-compose.yml" ]]; then
    echo "${path}/docker-compose.yml"
  else
    echo ""
  fi
}
