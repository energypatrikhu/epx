#!/bin/bash

if [[ ! -f "${EPX_HOME}/.config/minecraft.config" ]]; then
  echo "Error: Minecraft configuration file not found. Please configure '${EPX_HOME}/.config/minecraft.config' and run 'mc.install'."
  exit 1
fi

source "${EPX_HOME}/helpers/check-command-installed.sh"
_cci git

. "${EPX_HOME}/.config/minecraft.config"

if [[ ! -d "${MINECRAFT_PROJECT_DIR}" ]]; then
  echo "Error: Minecraft project directory does not exist. Please run 'mc.setup' first."
  exit 1
fi

if ! command -v git &>/dev/null; then
  echo "Error: git is not installed. Please install git to run this command."
  exit 1
fi

cd "${MINECRAFT_PROJECT_DIR}" || exit
if ! git pull; then
  echo "Error: Failed to update the Minecraft project."
  exit 1
fi

echo "Minecraft project updated successfully."
