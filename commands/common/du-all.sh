source "${EPX_HOME}/helpers/header.sh"

source "${EPX_HOME}/helpers/check-command-installed.sh"
_cci docker

docker images | awk '(NR>1) && (${2}!~/none/) {print ${1}":"${2}}' | xargs -L1 docker pull
