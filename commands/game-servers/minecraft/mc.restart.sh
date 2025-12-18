d.restart "mc-${1-}-server"
d.restart "mc-${1-}-backup" || true
