# Colorizes text using predefined color codes from EPX_COLORS associative array.
#
# This function wraps the provided text with ANSI color codes based on the
# specified color key. If the color key is found in EPX_COLORS, the text is
# formatted with that color and reset with the NC (No Color) code.
#
# Arguments:
#   $1 - color: The color key to look up in EPX_COLORS array (optional)
#   $2 - text: The text string to be colorized (optional)
#
# Globals:
#   EPX_COLORS - Associative array containing color code mappings
#
# Returns:
#   Echoes the colorized text if color key is found, otherwise echoes
#   the original text unchanged
#
# Example:
#   _c "RED" "Error message"
#   _c "GREEN" "Success message"
_c() {
  local color="${1-}"
  local text="${2-}"

  for key in "${!EPX_COLORS[@]}"; do
    if [[ "${color}" == "${key}" ]]; then
      text="${EPX_COLORS[${key}]}${text}${EPX_COLORS[NC]}"
      break
    fi
  done

  echo -e "${text}"
}
