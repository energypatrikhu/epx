_cci samba

echo "Restarting Samba service..."

if command -v service &> /dev/null; then
  if ! service smbd restart; then
    echo "Samba service 'smbd' not found using service command."
    exit 1
  else
    echo "Samba service restarted using service command."
    exit 0
  fi
elif command -v systemctl &> /dev/null; then
  if ! systemctl restart smbd; then
    echo "Failed to restart Samba service 'smbd' using systemctl."
    exit 1
  else
    echo "Samba service restarted using systemctl."
    exit 0
  fi
else
  echo "Cannot restart Samba services: neither systemctl nor service command found."
  exit 1
fi
