# Helper to print section header
_print_section() {
  local title="${1-}"
  echo ""
  echo -e "$(_c LIGHT_CYAN "▶ $title")"
  echo -e "$(_c LIGHT_CYAN "────────────────────────────────────────────────────────────────────────────────")"
}
