__epx_update_bees() {
  _cci wget tar make markdown jq

  . "${EPX_HOME}/.config/update-bees.config"

  APP_NAME=bees
  REPOSITORY=Zygo/${APP_NAME}

  # Check if the build directory exists
  if [ ! -d "${EPX_BEES_SOURCE_PATH}" ]; then
    echo -e "\n> Creating the build directory"
    mkdir -p "${EPX_BEES_SOURCE_PATH}"
  fi

  # Check if the '.version' file exists
  if [ -f "${EPX_BEES_SOURCE_PATH}"/.version ]; then
    # Get the version number from the '.-version' file
    CURRENT_VERSION=$(cat "${EPX_BEES_SOURCE_PATH}"/.version)
    echo -e "\n> Current version: ${CURRENT_VERSION}"
  else
    # Set the current version to 'unknown'
    CURRENT_VERSION="unknown"
    echo -e "\n> Current version: ${CURRENT_VERSION}"
  fi

  # Get the latest release from the app repository
  echo -e "\n> Getting the latest release from the ${APP_NAME} repository"
  LATEST_VERSION=$(curl "https://api.github.com/repos/${REPOSITORY}/tags" | jq -r '.[0].name')

  echo -e "\n> Latest version: ${LATEST_VERSION}"

  # Check if the latest version is the same as the current version
  if [ "${LATEST_VERSION}" == "${CURRENT_VERSION}" ]; then
    echo -e "\n> ${APP_NAME} is already up to date"
    cd - || return

    return
  fi

  # Set the build directory based on the latest version, remove the 'v' prefix
  BUILD_DIR=${EPX_BEES_SOURCE_PATH}/${APP_NAME}-${LATEST_VERSION:1}

  # Download the latest release
  echo -e "\n> Downloading the latest release: ${LATEST_VERSION}"
  wget -O "${EPX_BEES_SOURCE_PATH}"/"${LATEST_VERSION}".tar.gz "https://github.com/${REPOSITORY}/archive/refs/tags/${LATEST_VERSION}.tar.gz"

  # Extract the tarball
  echo -e "\n> Extracting the tarball"
  tar -xzf "${EPX_BEES_SOURCE_PATH}"/"${LATEST_VERSION}".tar.gz -C "${EPX_BEES_SOURCE_PATH}"

  # Change to the app directory
  echo -e "\n> Changing to the ${APP_NAME} directory"
  cd "${BUILD_DIR}" || return

  # Set version
  echo -e "\n> Setting the ${APP_NAME} version"
  sed -i "s/BEES_VERSION ?=.*/BEES_VERSION ?= ${LATEST_VERSION}/" ./Makefile

  # Build the project
  echo -e "\n> Building the ${APP_NAME} project"
  make

  # Install the project
  echo -e "\n> Installing the ${APP_NAME} project"
  make install

  # Copy service files
  echo -e "\n> Copying service files"
  cp -rf "${BUILD_DIR}"/scripts/*.service /etc/systemd/system/

  # Remove the build directory
  echo -e "\n> Removing the build directory"
  rm -rf "${BUILD_DIR}"

  # Remove the tarball
  echo -e "\n> Removing the tarball"
  rm -rf "${EPX_BEES_SOURCE_PATH}"/"${LATEST_VERSION}".tar.gz

  # Write version number to '.version' file
  echo -e "${LATEST_VERSION}" >"${EPX_BEES_SOURCE_PATH}"/.version

  echo -e "\n> ${APP_NAME} has been successfully updated to version ${LATEST_VERSION}"

  cd - || return
}
