#!/bin/bash

# Setup environment
PROFILE_DIR="/etc/profile.d"

# Add EPX_HOME and source epx.sh to the profile.d script
EPX_BIN="$PROFILE_DIR/00-epx.sh"
if [[ ! -f "$EPX_BIN" ]]; then
  echo "Creating $EPX_BIN"
  echo "export EPX_HOME=\"/usr/local/epx\"" | sudo tee "$EPX_BIN" >/dev/null
  echo ". \"\$EPX_HOME/epx.sh\"" | sudo tee -a "$EPX_BIN" >/dev/null
else
  echo "$EPX_BIN already exists, skipping creation."
fi

source "$EPX_BIN"

# Setup crontab for epx self-update
CRON_JOB="@daily root bash /usr/local/epx/crontab.sh"
CRON_FILE="/etc/cron.daily/epx-self-update"
if ! grep -qF "$CRON_JOB" "$CRON_FILE"; then
  echo "Adding self-update cron job to $CRON_FILE"
  echo "$CRON_JOB" | sudo tee -a "$CRON_FILE" >/dev/null
else
  echo "Self-update cron job already exists in $CRON_FILE, skipping addition."
fi
