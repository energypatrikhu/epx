__epx_update_bees() {
  _check_sudo
  _cci_pkg wget:wget tar:tar make:make markdown:markdown jq:jq

  local app_name="bees"
  local repository="Zygo/${app_name}"

  # Get the installed version of the app
  local installed_version="none"
  if command -v beesd &> /dev/null; then
    installed_version="$(beesd --help 2>&1 | grep -oP 'bees version \K[^\s]+')"
  fi

  # Get the latest release from the app repository
  echo -e "\n> Getting the latest release from the ${app_name} repository"
  local latest_version=$(curl "https://api.github.com/repos/${repository}/tags" | jq -r '.[0].name')

  echo -e "\n> Installed version: ${installed_version}"
  echo -e "> Latest version: ${latest_version}"

  # Check if the latest version is the same as the current version
  if [[ "${latest_version}" == "${installed_version}" ]]; then
    echo -e "\n> ${app_name} is already up to date"
    return
  fi

  # Setup temporary directories
  local tmp_dir="$(mktemp -d)"
  local build_dir="${tmp_dir}/${app_name}"
  echo -e "\n> Created temporary directory: ${tmp_dir}"

  # Download the latest release
  echo -e "\n> Downloading the latest release: ${latest_version}"
  wget -O "${tmp_dir}/${latest_version}.tar.gz" "https://github.com/${repository}/archive/refs/tags/${latest_version}.tar.gz"

  # Extract the tarball
  echo -e "\n> Extracting the tarball"
  tar -xzf "${tmp_dir}/${latest_version}.tar.gz" -C "${tmp_dir}"

  # Get the extracted directory name
  local extracted_dir="${tmp_dir}/${app_name}-${latest_version#v}"

  # Change to the app directory
  echo -e "\n> Changing to the ${app_name} directory"
  cd "${extracted_dir}"

  # Set version
  echo -e "\n> Setting the ${app_name} version"
  sed -i "s/BEES_VERSION ?=.*/BEES_VERSION ?= ${latest_version}/" ./Makefile

  # Build the project
  echo -e "\n> Building the ${app_name} project"
  make

  # Install the project
  echo -e "\n> Installing the ${app_name} project"
  make install

  # Copy service files
  echo -e "\n> Copying service files"
  cp -rf "${extracted_dir}"/scripts/*.service /etc/systemd/system/

  # Remove the temporary directory
  echo -e "\n> Removing the temporary directory"
  rm -rf "${tmp_dir}"

  echo -e "\n> ${app_name} has been successfully updated to version ${latest_version}"
}
