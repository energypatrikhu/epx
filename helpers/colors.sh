# colors.sh - Terminal color definitions for EPX scripts
#
# This file defines an associative array of ANSI color codes that can be used
# to colorize terminal output in bash scripts.
#
# Usage:
#   echo -e "${EPX_COLORS[LIGHT_BLUE]}This is blue text${EPX_COLORS[NC]}"
# Functions:
#   _c <color> <text> - Colorizes the given text using the specified color key
#
# Available Colors:
#   Light variants (bold/bright):
#     - LIGHT_BLUE, LIGHT_GREEN, LIGHT_RED, LIGHT_YELLOW
#     - LIGHT_CYAN, LIGHT_PURPLE, LIGHT_GRAY
#
#   Standard variants:
#     - RED, GREEN, BROWN, BLUE, PURPLE, CYAN, WHITE
#     - DARK_GRAY
#
#   Special:
#     - NC (No Color) - Use to reset color formatting
#
# Note:
#   Always use ${EPX_COLORS[NC]} after colored text to prevent color bleeding
#   into subsequent terminal output.
declare -A EPX_COLORS
EPX_COLORS=(
  ["LIGHT_BLUE"]="\033[1;34m"
  ["LIGHT_GREEN"]="\033[1;32m"
  ["LIGHT_RED"]="\033[1;31m"
  ["LIGHT_YELLOW"]="\033[1;33m"
  ["LIGHT_CYAN"]="\033[1;36m"
  ["LIGHT_PURPLE"]="\033[1;35m"
  ["LIGHT_GRAY"]="\033[1;30m"
  ["DARK_GRAY"]="\033[0;30m"
  ["RED"]="\033[0;31m"
  ["GREEN"]="\033[0;32m"
  ["BROWN"]="\033[0;33m"
  ["BLUE"]="\033[0;34m"
  ["PURPLE"]="\033[0;35m"
  ["CYAN"]="\033[0;36m"
  ["WHITE"]="\033[0;37m"
  ["NC"]="\033[0m" # No color
)
