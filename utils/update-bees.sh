#!/bin/bash

__epx_update_bees() {
  . "$EPX_PATH/.config/update-bees.config"

  APP_NAME=bees
  REPOSITORY=Zygo/$APP_NAME

  # Check if the build directory exists
  if [ ! -d "$EPX_BEES_SOURCE_PATH" ]; then
    __epx_echo "\n> Creating the build directory"
    mkdir -p "$EPX_BEES_SOURCE_PATH"
  fi

  # Check if the '.version' file exists
  if [ -f "$EPX_BEES_SOURCE_PATH"/.version ]; then
    # Get the version number from the '.-version' file
    CURRENT_VERSION=$(cat "$EPX_BEES_SOURCE_PATH"/.version)
    __epx_echo "\n> Current version: $CURRENT_VERSION"
  else
    # Set the current version to 'unknown'
    CURRENT_VERSION="unknown"
    __epx_echo "\n> Current version: $CURRENT_VERSION"
  fi

  # Get the latest release from the app repository
  __epx_echo "\n> Getting the latest release from the $APP_NAME repository"
  LATEST_VERSION=$(curl "https://api.github.com/repos/$REPOSITORY/tags" | jq -r '.[0].name')

  __epx_echo "\n> Latest version: $LATEST_VERSION"

  # Check if the latest version is the same as the current version
  if [ "$LATEST_VERSION" == "$CURRENT_VERSION" ]; then
    __epx_echo "\n> $APP_NAME is already up to date"
    cd - || return

    return
  fi

  # Set the build directory based on the latest version, remove the 'v' prefix
  BUILD_DIR=$EPX_BEES_SOURCE_PATH/$APP_NAME-${LATEST_VERSION:1}

  # Download the latest release
  __epx_echo "\n> Downloading the latest release: $LATEST_VERSION"
  wget -O "$EPX_BEES_SOURCE_PATH"/"$LATEST_VERSION".tar.gz "https://github.com/$REPOSITORY/archive/refs/tags/$LATEST_VERSION.tar.gz"

  # Extract the tarball
  __epx_echo "\n> Extracting the tarball"
  tar -xzf "$EPX_BEES_SOURCE_PATH"/"$LATEST_VERSION".tar.gz -C "$EPX_BEES_SOURCE_PATH"

  # Change to the app directory
  __epx_echo "\n> Changing to the $APP_NAME directory"
  cd "$BUILD_DIR" || return

  # Set version
  __epx_echo "\n> Setting the $APP_NAME version"
  sed -i "s/BEES_VERSION ?=.*/BEES_VERSION ?= $LATEST_VERSION/" ./Makefile

  # Build the project
  __epx_echo "\n> Building the $APP_NAME project"
  make

  # Install the project
  __epx_echo "\n> Installing the $APP_NAME project"
  make install

  # Copy service files
  __epx_echo "\n> Copying service files"
  cp -rf "$BUILD_DIR"/scripts/*.service /etc/systemd/system/

  # Remove the build directory
  __epx_echo "\n> Removing the build directory"
  rm -rf "$BUILD_DIR"

  # Remove the tarball
  __epx_echo "\n> Removing the tarball"
  rm -rf "$EPX_BEES_SOURCE_PATH"/"$LATEST_VERSION".tar.gz

  # Write version number to '.version' file
  __epx_echo "$LATEST_VERSION" >"$EPX_BEES_SOURCE_PATH"/.version

  __epx_echo "\n> $APP_NAME has been successfully updated to version $LATEST_VERSION"

  cd - || return
}
