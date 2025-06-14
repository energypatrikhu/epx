#!/bin/bash

du-all() {
  docker images | awk '(NR>1) && ($2!~/none/) {print $1":"$2}' | xargs -L1 docker pull
}

dcu() {
  docker compose up -d
}
