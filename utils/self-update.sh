__epx_self_update() {
  if [ ! -d $EPX_PATH ]; then
    echo "
  > The '$EPX_PATH' directory does not exist"
    return
  fi

  echo $EPX_PATH

  cd $EPX_PATH

  git pull

  source ~/.bashrc

  cd -
}
