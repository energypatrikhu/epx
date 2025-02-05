#!/bin/bash

APP_NAME=bees
BASE_BUILD_DIR=/storage/builds/$APP_NAME
REPOSITORY=Zygo/$APP_NAME

__update_bees() {
  # Check if the build directory exists
  if [ ! -d $BASE_BUILD_DIR ]; then
    echo "
> Creating the build directory"
    mkdir -p $BASE_BUILD_DIR
  fi

  # Check if the '.version' file exists
  if [ -f $BASE_BUILD_DIR/.version ]; then
    # Get the version number from the '.-version' file
    CURRENT_VERSION=$(cat $BASE_BUILD_DIR/.version)
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
    return
  fi

  # Set the build directory based on the latest version, remove the 'v' prefix
  BUILD_DIR=$BASE_BUILD_DIR/$APP_NAME-${LATEST_VERSION:1}

  # Download the latest release
  echo "
> Downloading the latest release: $LATEST_VERSION"
  wget -O $BASE_BUILD_DIR/$LATEST_VERSION.tar.gz "https://github.com/$REPOSITORY/archive/refs/tags/$LATEST_VERSION.tar.gz"

  # Extract the tarball
  echo "
> Extracting the tarball"
  tar -xzf $BASE_BUILD_DIR/$LATEST_VERSION.tar.gz -C $BASE_BUILD_DIR

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
  rm $BASE_BUILD_DIR/$LATEST_VERSION.tar.gz

  # Write version number to '.version' file
  echo $LATEST_VERSION >$BASE_BUILD_DIR/.version

  echo "
> $APP_NAME has been successfully updated to version $LATEST_VERSION"
}
