d.help() {
  printf "[${EPX_COLORS["LIGHT_BLUE"]}Docker - Help${EPX_COLORS["NC"]}] ${EPX_COLORS["LIGHT_YELLOW"]}Usage: d.help <command>${EPX_COLORS["NC"]}\n"
  printf "  ${EPX_COLORS["LIGHT_BLUE"]}Commands:${EPX_COLORS["NC"]}\n"
  printf "    ${EPX_COLORS["LIGHT_BLUE"]}d.start${EPX_COLORS["NC"]} - Start a container\n"
  printf "    ${EPX_COLORS["LIGHT_BLUE"]}d.restart${EPX_COLORS["NC"]} - Restart a container\n"
  printf "    ${EPX_COLORS["LIGHT_BLUE"]}d.stop${EPX_COLORS["NC"]} - Stop a container\n"
  printf "    ${EPX_COLORS["LIGHT_BLUE"]}d.shell${EPX_COLORS["NC"]} - Open a shell in a container\n"
  printf "    ${EPX_COLORS["LIGHT_BLUE"]}d.logs${EPX_COLORS["NC"]} - View logs of a container\n"
  printf "    ${EPX_COLORS["LIGHT_BLUE"]}d.list${EPX_COLORS["NC"]} - List all containers\n"
  printf "    ${EPX_COLORS["LIGHT_BLUE"]}d.help${EPX_COLORS["NC"]} - Display this help message\n"
  printf "  ${EPX_COLORS["LIGHT_BLUE"]}Aliases:${EPX_COLORS["NC"]}\n"
  printf "    ${EPX_COLORS["LIGHT_BLUE"]}d${EPX_COLORS["NC"]} - Docker\n"
  printf "    ${EPX_COLORS["LIGHT_BLUE"]}dc${EPX_COLORS["NC"]} - Docker Compose\n"
}
