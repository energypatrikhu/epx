#!/bin/bash

source "${EPX_HOME}/helpers/colorize.sh"
source "${EPX_HOME}/helpers/colors.sh"

echo -e "[$(_c LIGHT_BLUE "Minecraft - Help")]"
echo -e "  $(_c CYAN "Commands:")"
echo -e "    $(_c LIGHT_CYAN "mc") - Start Minecraft Server"
echo -e "    $(_c LIGHT_CYAN "mc.create") - Create a new Minecraft server configuration file"
echo -e "    $(_c LIGHT_CYAN "mc.install") - Download required files for running a Minecraft server"
echo -e "    $(_c LIGHT_CYAN "mc.update") - Update Minecraft server files"
echo -e "    $(_c LIGHT_CYAN "mc.help") - Display this help message"
