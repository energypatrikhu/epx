# Generates bash completion suggestions for the current word being typed.
#
# This function is designed to be used with the bash completion system.
# It compares the current word being typed against a list of possible options
# and populates the COMPREPLY array with matching completions.
#
# Arguments:
#   $* - Space-separated list of possible completion options
#
# Variables:
#   COMP_WORDS - Array of words in the current command line (bash completion variable)
#   COMP_CWORD - Index of the current word being completed (bash completion variable)
#   COMPREPLY  - Array that will be populated with completion suggestions (bash completion variable)
#
# Example:
#   complete -F _autocomplete mycommand
#   # Where _autocomplete is called with possible options like:
#   # _autocomplete "option1 option2 option3"
_autocomplete() {
  local cur opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  opts="${*}"

  mapfile -t COMPREPLY < <(compgen -W "${opts}" -- "${cur}")
}
