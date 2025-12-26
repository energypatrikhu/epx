_cci samba

echo "Restarting Samba service..."

if command -v service &> /dev/null; then
  service smbd restart
  echo "Samba service restarted using service command."
elif command -v systemctl &> /dev/null; then
  systemctl restart smbd
  echo "Samba service restarted using systemctl."
else
  echo "Cannot restart Samba services: neither systemctl nor service command found."
  exit 1
fi
