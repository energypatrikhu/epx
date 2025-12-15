# shortname,gameservername,gamename,os
# ac,acserver,Assetto Corsa,ubuntu-24.04
# ahl,ahlserver,Action Half-Life,ubuntu-24.04
# ahl2,ahl2server,Action: Source,ubuntu-24.04

# List of available game servers
# Example:
# Game servers:
#   Assetto Corsa (ac)
#   Action Half-Life (ahl)
#   Action: Source (ahl2)

available_servers="$(curl -sL https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/refs/heads/master/lgsm/data/serverlist.csv)"
opt_find=""
if [[ -n "${1-}" ]]; then
  opt_find="${1}"
  available_servers="$(echo "${available_servers}" | awk -F',' -v search="${opt_find}" 'NR==1 {print $1","$3; next} tolower($1) ~ tolower(search) || tolower($3) ~ tolower(search) {print $1","$3}')"
else
  available_servers="$(echo "${available_servers}" | awk -F',' '{print $1","$3}')"
fi

echo -e "[$(_c LIGHT_BLUE "LinuxGSM")] $(_c LIGHT_GREEN "Available game servers:")"
echo "${available_servers}" | tail -n +2 | while IFS=, read -r shortname gamename; do
  echo -e "  $(_c LIGHT_YELLOW "${gamename}") $(_c LIGHT_CYAN "(${shortname})")"
done
