#!/bin/bash

# Setup environment
PROFILE_DIR="/etc/profile.d"

# Add EPX_PATH and source epx.sh to the profile.d script
EPX_BIN="$PROFILE_DIR/00-epx.sh"
if [[ ! -f "$EPX_BIN" ]]; then
  echo "Creating $EPX_BIN"
  echo "export EPX_PATH=\"/usr/local/epx\"" | sudo tee "$EPX_BIN" >/dev/null
  echo "source \"\$EPX_PATH/epx.sh\"" | sudo tee -a "$EPX_BIN" >/dev/null
else
  echo "$EPX_BIN already exists, skipping creation."
fi
