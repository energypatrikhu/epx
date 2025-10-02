#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
  set -o xtrace
fi

# Check if git is installed
if ! command -v git &>/dev/null; then
  echo "Git is not installed. Please install Git to use EPX."
  exit 1
fi

# Check if EPX_HOME is set, if not, set it to /usr/local/epx
if [[ -z "${EPX_HOME-}" ]]; then
  EPX_HOME="/usr/local/epx"
fi

# Create EPX_HOME directory if it doesn't exist
mkdir -p "${EPX_HOME}"

# Clone the EPX repository
if [[ ! -d "${EPX_HOME}/.git" ]]; then
  echo "Cloning EPX repository into ${EPX_HOME}..."
  git clone https://github.com/energypatrikhu/epx.git "${EPX_HOME}"
else
  echo "EPX repository already exists in ${EPX_HOME}. Pulling latest changes..."
  cd "${EPX_HOME}" || exit
  git reset --hard HEAD
  git clean -f -d
  git pull
fi

# Set permissions for the EPX_HOME directory
chmod -R a+x "${EPX_HOME}"

# Run post-installation script if it exists
if [[ -f "${EPX_HOME}/post-install.sh" ]]; then
  echo "Running post-installation script..."
  "${EPX_HOME}/post-install.sh"
else
  echo "Post-installation script not found, skipping."
fi
