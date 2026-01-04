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
#   if check-compose-file "/path/to/project"
#     echo "Found compose file"
#   end
function check-compose-file
  set -l path (test -n "$argv" && echo "$argv[1]" || echo ".")
  set -l compose_files "docker-compose.yml" "docker-compose.yaml" "compose.yml" "compose.yaml"

  for file in $compose_files
    if test -f "$path/$file"
      return 0
    end
  end

  return 1
end
