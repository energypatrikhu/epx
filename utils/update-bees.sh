__epx_update_bees() {
  . $EPX_PATH/.config/update-bees.config

  APP_NAME=bees
  REPOSITORY=Zygo/$APP_NAME

  # Check if the build directory exists
  if [ ! -d $EPX_BEES_SOURCE_PATH ]; then
    printf "\n> Creating the build directory\n"
    mkdir -p $EPX_BEES_SOURCE_PATH
  fi

  # Check if the '.version' file exists
  if [ -f $EPX_BEES_SOURCE_PATH/.version ]; then
    # Get the version number from the '.-version' file
    CURRENT_VERSION=$(cat $EPX_BEES_SOURCE_PATH/.version)
    printf "\n> Current version: %s\n" "$CURRENT_VERSION"
  else
    # Set the current version to 'unknown'
    CURRENT_VERSION="unknown"
    printf "\n> Current version: %s\n" "$CURRENT_VERSION"
  fi

  # Get the latest release from the app repository
  printf "\n> Getting the latest release from the %s repository\n" "$APP_NAME"
  LATEST_VERSION=$(curl "https://api.github.com/repos/$REPOSITORY/tags" | jq -r '.[0].name')

  printf "\n> Latest version: %s\n" "$LATEST_VERSION"

  # Check if the latest version is the same as the current version
  if [ "$LATEST_VERSION" == "$CURRENT_VERSION" ]; then
    printf "\n> %s is already up to date\n" "$APP_NAME"
    cd -
    return
  fi

  # Set the build directory based on the latest version, remove the 'v' prefix
  BUILD_DIR=$EPX_BEES_SOURCE_PATH/$APP_NAME-${LATEST_VERSION:1}

  # Download the latest release
  printf "\n> Downloading the latest release: %s\n" "$LATEST_VERSION"
  wget -O $EPX_BEES_SOURCE_PATH/$LATEST_VERSION.tar.gz "https://github.com/$REPOSITORY/archive/refs/tags/$LATEST_VERSION.tar.gz"

  # Extract the tarball
  printf "\n> Extracting the tarball\n"
  tar -xzf $EPX_BEES_SOURCE_PATH/$LATEST_VERSION.tar.gz -C $EPX_BEES_SOURCE_PATH

  # Change to the app directory
  printf "\n> Changing to the %s directory\n" "$APP_NAME"
  cd $BUILD_DIR

  # Set version
  printf "\n> Setting the %s version\n" "$APP_NAME"
  sed -i "s/BEES_VERSION ?=.*/BEES_VERSION ?= $LATEST_VERSION/" ./Makefile

  # Build the project
  printf "\n> Building the %s project\n" "$APP_NAME"
  make

  # Install the project
  printf "\n> Installing the %s project\n" "$APP_NAME"
  make install

  # Remove the build directory
  printf "\n> Removing the build directory\n"
  rm -rf $BUILD_DIR

  # Remove the tarball
  rm $EPX_BEES_SOURCE_PATH/$LATEST_VERSION.tar.gz

  # Write version number to '.version' file
  printf "%s\n" "$LATEST_VERSION" >$EPX_BEES_SOURCE_PATH/.version

  printf "\n> %s has been successfully updated to version %s\n" "$APP_NAME" "$LATEST_VERSION"

  cd -
}
