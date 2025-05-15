#!/bin/bash

du-all() {
  docker images | awk '(NR>1) && ($2!~/none/) {print $1":"$2}' | xargs -L1 docker pull
}

dcu() {
  docker compose up -d
}

h() {
  __epx_echo "h    -> Help (This command)"
  __epx_echo "dhelp    -> Docker commands"
  __epx_echo "mc-help    -> Minecraft commands"
  __epx_echo "move    -> Move files with rsync"
  __epx_echo "copy    -> Copy files with rsync"
  __epx_echo "zst    -> Compress dir/file to zstd archive format"
  __epx_echo "unzst    -> Decompress zstd archive"
  __epx_echo "archive    -> Compress dir/file to .tar archive"
  __epx_echo "unarchive    -> Decompress .tar file"
}

dhelp() {
  __epx_echo "h   -> Help"
  __epx_echo "dhelp   -> Docker commands (This command)"
  __epx_echo "du-all   -> Update all docker image to latest"
  __epx_echo "dcu   -> Alias for 'docker compose up -d'"
}
