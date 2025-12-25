_cci samba

if command -v service &> /dev/null; then
  service smbd restart
else if command -v systemctl &> /dev/null; then
  systemctl restart smbd
else
  echo "Cannot restart Samba services: neither systemctl nor service command found."
  exit 1
fi
