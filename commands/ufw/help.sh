#!/bin/bash

ufw.help() {
  __epx_echo "[$(_c LIGHT_CYAN "UFW - Help")]"
  __epx_echo "  $(_c LIGHT_CYAN "Commands:")"
  __epx_echo "    $(_c LIGHT_CYAN "ufw.add") - Add a firewall rule"
  __epx_echo "    $(_c LIGHT_CYAN "ufw.del") - Delete a firewall rule"
  __epx_echo "    $(_c LIGHT_CYAN "ufw.list") - List firewall rules"
  __epx_echo "    $(_c LIGHT_CYAN "ufw.help") - Display this help message"
}
