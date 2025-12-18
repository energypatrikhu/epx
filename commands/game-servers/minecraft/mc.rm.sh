d.rm "mc-${1-}-server"

if docker ps -a --format '{{.Names}}' | grep -q "^mc-${1-}-backup$"; then
  d.rm "mc-${1-}-backup" || true
fi
