_help() {
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")] Usage: $(_c LIGHT_YELLOW "ufw.list")"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")] List all rules in UFW (Uncomplicated Firewall)"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")]"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")] Options:"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")]   -h, --help     Show this help message"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")]   --in-used      List currently used ports with associated programs"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")]"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")] Examples:"
  echo -e "[$(_c LIGHT_BLUE "UFW - List Rules")]   ufw.list"
}

opt_help=false
opt_list_inused=false
for arg in "$@"; do
  if [[ "${arg}" == -* ]]; then
    if [[ "${arg}" =~ ^-*h(elp)?$ ]]; then
      opt_help=true
    else if [[ "${arg}" == --in-used ]]; then
      opt_list_inused=true
    fi
  fi
done

if [[ "${opt_help}" == "true" ]]; then
  _help
  exit
fi

_cci_pkg ufw:ufw

if [[ "${opt_list_inused}" == "true" ]]; then
  # List currently used ports in a table: Proto | Port | Program
  ss -tulnp | awk '
    NR>1 {
      proto=$1
      split($5, a, ":")
      port=a[length(a)]
      gsub(/users:\(\("([^"]+).*/, "\\1", $NF)
      program=($NF ~ /users:/ ? $NF : "-")
      key = proto ":" port ":" program
      if (!seen[key]++) {
        printf "%-6s %-6s %s\n", proto, port, program
      }
    }
  ' | sort -k2,2n | awk '
    BEGIN { print "Proto  Port   Program"; print "--------------------------" }
    { print }
  '
  exit
fi

ufw status numbered
