__epx_update_bees() {
  . $EPX_PATH/.config/update-bees.config

  APP_NAME=bees
  REPOSITORY=Zygo/$APP_NAME

  # Check if the build directory exists
  if [ ! -d $EPX_BEES_SOURCE_PATH ]; then
    echo "
> Creating the build directory"
    mkdir -p $EPX_BEES_SOURCE_PATH
  fi

  # Check if the '.version' file exists
  if [ -f $EPX_BEES_SOURCE_PATH/.version ]; then
    # Get the version number from the '.-version' file
    CURRENT_VERSION=$(cat $EPX_BEES_SOURCE_PATH/.version)
    echo "
> Current version: $CURRENT_VERSION"
  else
    # Set the current version to 'unknown'
    CURRENT_VERSION="unknown"
    echo "
> Current version: $CURRENT_VERSION"
  fi

  # Get the latest release from the app repository
  echo "
> Getting the latest release from the $APP_NAME repository"
  LATEST_VERSION=$(curl "https://api.github.com/repos/$REPOSITORY/tags" | jq -r '.[0].name')

  echo "
> Latest version: $LATEST_VERSION"

  # Check if the latest version is the same as the current version
  if [ "$LATEST_VERSION" == "$CURRENT_VERSION" ]; then
    echo "
> $APP_NAME is already up to date"
    cd -
    return
  fi

  # Set the build directory based on the latest version, remove the 'v' prefix
  BUILD_DIR=$EPX_BEES_SOURCE_PATH/$APP_NAME-${LATEST_VERSION:1}

  # Download the latest release
  echo "
> Downloading the latest release: $LATEST_VERSION"
  wget -O $EPX_BEES_SOURCE_PATH/$LATEST_VERSION.tar.gz "https://github.com/$REPOSITORY/archive/refs/tags/$LATEST_VERSION.tar.gz"

  # Extract the tarball
  echo "
> Extracting the tarball"
  tar -xzf $EPX_BEES_SOURCE_PATH/$LATEST_VERSION.tar.gz -C $EPX_BEES_SOURCE_PATH

  # Change to the app directory
  echo "
> Changing to the $APP_NAME directory"
  cd $BUILD_DIR

  # Set version
  echo "
> Setting the $APP_NAME version"
  sed -i "s/BEES_VERSION ?=.*/BEES_VERSION ?= $LATEST_VERSION/" ./Makefile

  # Build the project
  echo "
> Building the $APP_NAME project"
  make

  # Install the project
  echo "
> Installing the $APP_NAME project"
  make install

  # Remove the build directory
  echo "
> Removing the build directory"
  rm -rf $BUILD_DIR

  # Remove the tarball
  rm $EPX_BEES_SOURCE_PATH/$LATEST_VERSION.tar.gz

  # Write version number to '.version' file
  echo $LATEST_VERSION >$EPX_BEES_SOURCE_PATH/.version

  echo "
> $APP_NAME has been successfully updated to version $LATEST_VERSION"

  cd -
}
