#!/bin/bash

du-all() {
  docker images | awk '(NR>1) && ($2!~/none/) {print $1":"$2}' | xargs -L1 docker pull
}
dls() {
  docker ps
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
  printf "du-all   -> Update all docker image to latest\n"
  printf "dls   -> List containers\n"
  printf "dup   -> Start container ( dup <id or name> )\n"
  printf "ds   -> Stop container ( ds <id or name> )\n"
  printf "dcu   -> Alias for 'docker compose up -d'\n"
}
