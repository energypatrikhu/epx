du-all() {
  docker images | awk '(NR>1) && ($2!~/none/) {print $1":"$2}' | xargs -L1 docker pull
}
dps() {
  docker ps
}
dls() {
  docker container ls
}
dup() {
  docker container start "$@"
}
ds() {
  docker container stop "$@"
}
dcu() {
  docker compose up -d
}

dcf() {
  fbasename=$(basename -- "$@")

  docker compose -f "/storage/configs/compose/${fbasename}.yml" pull
  echo ""

  docker compose -p "${fbasename}" -f "/storage/configs/compose/${fbasename}.yml" up -d
  echo ""
}
dcf-all() {
  for f in /storage/configs/compose/*.yml; do
    dcf $(basename -- "$f" .yml)
  done

  docker image prune --all --force
}

__dcf-mc() {
  fbasename=$(basename -- "$3")
  project_name=$(echo "${fbasename}" | sed -e 's/[][]//g' | sed -e 's/,/-/g' | sed -e 's/ /_/g' | sed -e 's/^_//g' | sed -e 's/_$//g')

  echo "
Starting $2 Minecraft Server"
  docker compose -p "${project_name}" --env-file "/storage/games/minecraft/@modpacks/${fbasename}.env" -f "/storage/configs/compose/custom/itzg-minecraft-server-$1.yml" up -d
  echo ""
}
mc-curseforge() {
  __dcf-mc "curseforge" "CurseForge" "$1"
}
mc-feedthebeast() {
  __dcf-mc "feedthebeast" "Feed The Beast" "$1"
}
mc-modrinth() {
  __dcf-mc "modrinth" "Modrinth" "$1"
}
mc-vanilla() {
  __dcf-mc "vanilla" "Vanilla" "$1"
}
mc-forge() {
  __dcf-mc "forge" "Forge" "$1"
}

h() {
  echo "
h	  -> Help (This command)
dhelp	  -> Docker commands
mc-help	  -> Minecraft commands
move	  -> Move files with rsync
copy	  -> Copy files with rsync
zst	  -> Compress dir/file to zstd archive format
unzst	  -> Decompress zstd archive
archive	  -> Compress dir/file to .tar archive
unarchive -> Decompress .tar file
"
}

dhelp() {
  echo "
h	-> Help
dhelp	-> Docker commands (This command)
mc-help	-> Minecraft commands
du-all	-> Update all docker image to latest
dps	-> List running containers
dls	-> List containers
dup	-> Start container ( dup <id or name> )
ds	-> Stop container ( ds <id or name> )
dcu	-> Alias for 'docker compose up -d'
dcf	-> Alias for 'docker compose -f \"/storage/configs/compose/<filename>.yml\" -d'
dcf-all	-> Check and update all compose files located in '/storage/configs/compose'
"
}

mc-help() {
  echo "
h	        -> Help
dhelp	        -> Docker commands
mc-help	        -> Minecraft commands (This command)
mc-curseforge	-> Start CurseForge Minecraft Server (mc-curseforge <server.env>)
mc-feedthebeast	-> Start Feed The Beast Minecraft Server (mc-feedthebeast <server.env>)
mc-modrinth	-> Start Modrinth Minecraft Server (mc-modrinth <server.env>)
mc-vanilla	-> Start Vanilla Minecraft Server (mc-vanilla <server.env>)
mc-forge	-> Start Forge Minecraft Server (mc-forge <server.env>)
"
}
