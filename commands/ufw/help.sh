#!/bin/bash

ufw.help() {
  __epx_echo "[$(_c LIGHT_BLUE \"UFW - Help\")] $(_c LIGHT_YELLOW \"Usage: ufw.help <command >\")"
  __epx_echo "  $(_c LIGHT_BLUE \"Commands:\")"
  __epx_echo "    $(_c LIGHT_BLUE \"ufw.add\") - Add a firewall rule"
  __epx_echo "    $(_c LIGHT_BLUE \"ufw.del\") - Delete a firewall rule"
  __epx_echo "    $(_c LIGHT_BLUE \"ufw.list\") - List firewall rules"
  __epx_echo "    $(_c LIGHT_BLUE \"ufw.help\") - Display this help message"
}
