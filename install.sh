#!/bin/bash
# Install script for EPX CLI

# Check if git is installed
if ! command -v git &>/dev/null; then
  echo "Git is not installed. Please install Git to use EPX."
  exit 1
fi

# Check if EPX_PATH is set, if not, set it to /usr/local/epx
if [ -z "$EPX_PATH" ]; then
  EPX_PATH="/usr/local/epx"
fi

# Create EPX_PATH directory if it doesn't exist
mkdir -p "$EPX_PATH"

# Clone the EPX repository
if [ ! -d "$EPX_PATH/.git" ]; then
  echo "Cloning EPX repository into $EPX_PATH..."
  git clone https://github.com/energypatrikhu/epx.git "$EPX_PATH"
else
  echo "EPX repository already exists in $EPX_PATH. Pulling latest changes..."
  cd "$EPX_PATH" || exit
  git pull
fi

# Set permissions for the EPX_PATH directory
chmod -R a+x "$EPX_PATH"

# Run post-installation script if it exists
if [ -f "$EPX_PATH/post-install.sh" ]; then
  echo "Running post-installation script..."
  "$EPX_PATH/post-install.sh"
else
  echo "Post-installation script not found, skipping."
fi
