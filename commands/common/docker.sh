#!/bin/bash

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
  printf "\n"

  docker compose -p "${fbasename}" -f "/storage/configs/compose/${fbasename}.yml" up -d
  printf "\n"
}
dcf-all() {
  for f in /storage/configs/compose/*.yml; do
    dcf "$(basename -- "$f" .yml)"
  done

  docker image prune --all --force
}

__dcf-mc() {
  fbasename=$(basename -- "$3")
  project_name=$(echo "${fbasename}" | sed -e 's/[][]//g' | sed -e 's/,/-/g' | sed -e 's/ /_/g' | sed -e 's/^_//g' | sed -e 's/_$//g')

  printf "\nStarting %s Minecraft Server\n" "$2"
  docker compose -p "${project_name}" --env-file "/storage/games/minecraft/@modpacks/${fbasename}.env" -f "/storage/configs/compose/custom/itzg-minecraft-server-$1.yml" up -d
  printf "\n"
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
  printf "h    -> Help (This command)\n"
  printf "dhelp    -> Docker commands\n"
  printf "mc-help    -> Minecraft commands\n"
  printf "move    -> Move files with rsync\n"
  printf "copy    -> Copy files with rsync\n"
  printf "zst    -> Compress dir/file to zstd archive format\n"
  printf "unzst    -> Decompress zstd archive\n"
  printf "archive    -> Compress dir/file to .tar archive\n"
  printf "unarchive    -> Decompress .tar file\n"
}

dhelp() {
  printf "h   -> Help\n"
  printf "dhelp   -> Docker commands (This command)\n"
  printf "mc-help   -> Minecraft commands\n"
  printf "du-all   -> Update all docker image to latest\n"
  printf "dps   -> List running containers\n"
  printf "dls   -> List containers\n"
  printf "dup   -> Start container ( dup <id or name> )\n"
  printf "ds   -> Stop container ( ds <id or name> )\n"
  printf "dcu   -> Alias for 'docker compose up -d'\n"
  printf "dcf   -> Alias for 'docker compose -f \"/storage/configs/compose/<filename>.yml\" -d'\n"
  printf "dcf-all   -> Check and update all compose files located in '/storage/configs/compose'\n"
}

mc-help() {
  printf "h   -> Help\n"
  printf "dhelp   -> Docker commands\n"
  printf "mc-help   -> Minecraft commands (This command)\n"
  printf "mc-curseforge   -> Start CurseForge Minecraft Server (mc-curseforge <server.env>)\n"
  printf "mc-feedthebeast   -> Start Feed The Beast Minecraft Server (mc-feedthebeast <server.env>)\n"
  printf "mc-modrinth   -> Start Modrinth Minecraft Server (mc-modrinth <server.env>)\n"
  printf "mc-vanilla   -> Start Vanilla Minecraft Server (mc-vanilla <server.env>)\n"
  printf "mc-forge   -> Start Forge Minecraft Server (mc-forge <server.env>)\n"
}
