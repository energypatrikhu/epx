# directory: /storage/configs/compose
# compose file: /storage/configs/compose/pihole.yml
# container: pihole

COMPOSE_DIRECTORY=/storage/configs/compose
POSTPONE_CONTAINERS=("pihole")
POST_UPDATE_CONTAINERS=()

update_compose() {
  COMPOSE_FILE=$1
  CONTAINER=$(basename $COMPOSE_FILE .yml)
  ALLOW_CRITICAL_UPDATE=$2

  # Skip container if it's not running
  if [ "$(docker ps -q -f name=$CONTAINER)" == "" ]; then
    echo "  > Skipping $CONTAINER as it's not running"
    return
  fi

  # Check if the container is in the critical containers list
  if [[ " ${POSTPONE_CONTAINERS[@]} " =~ " ${CONTAINER} " ]]; then
    if [ "$ALLOW_CRITICAL_UPDATE" != "true" ]; then
      echo "  > Postponing $CONTAINER update"
      POST_UPDATE_CONTAINERS+=($CONTAINER)
      return
    fi
  fi

  echo "  > Updating $CONTAINER"

  docker compose -f $COMPOSE_FILE pull >/dev/null 2>&1
  docker compose -f $COMPOSE_FILE -p $CONTAINER up -d >/dev/null 2>&1
}

__epx_auto_update_compose() {
  echo "> Updating compose files"
  for COMPOSE_DIR in $COMPOSE_DIRECTORY/*.yml; do
    update_compose $COMPOSE_DIR "false"
  done

  echo "
> Updating postponed containers"
  for CONTAINER in ${POST_UPDATE_CONTAINERS[@]}; do
    update_compose $COMPOSE_DIRECTORY/$CONTAINER.yml "true"
  done

  echo "
> Cleaning up"
  docker image prune --all --force
}
