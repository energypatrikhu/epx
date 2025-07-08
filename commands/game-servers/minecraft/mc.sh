#!/bin/bash

if [[ ! -f "$EPX_HOME/.config/minecraft.config" ]]; then
  return 1
fi

. "$EPX_HOME/.config/minecraft.config"

__epx_mc__project_base="$MINECRAFT_PROJECT_DIR"
__epx_mc__compose_base="$__epx_mc__project_base/compose"
__epx_mc__config_env_base="$__epx_mc__project_base/configs"

__epx_mc__server_dir="$MINECRAFT_SERVERS_DIR"
__epx_mc__backup_dir="$MINECRAFT_BACKUPS_DIR"

if [[ ! -d "$__epx_mc__project_base" ]]; then
  echo "Error: Minecraft project directory does not exist. Please run 'mc.install' first."
  return 1
fi

__epx-mc-get-env-value() {
  local config_env="$1"
  local var_name="$2"
  grep -iE "^$var_name\s*=" "$config_env" | sed -E "s/^$var_name\s*=\s*//I; s/[[:space:]]*$//"
}
__epx-mc-get-java-type() {
  local config_env="$1"
  local java_version=$(__epx-mc-get-env-value "$config_env" "JAVA_VERSION")

  # if version 8 use "graalvm-ce"
  # else use "graalvm"
  if [[ "$java_version" == "8" ]]; then
    echo "graalvm-ce"
  else
    echo "graalvm"
  fi
}
__epx-mc-set-flags() {
  local config_env="$1"
  local tmp_env_file="$2"
  local java_version=$(__epx-mc-get-env-value "$config_env" "JAVA_VERSION")

  # If JAVA_VERSION < 17 use AIKAR, else use MEOWICE flags
  if [[ "$java_version" -lt 17 ]]; then
    echo "USE_AIKAR_FLAGS = true" >>"$tmp_env_file"
  else
    echo "USE_MEOWICE_FLAGS = true" >>"$tmp_env_file"
    echo "USE_MEOWICE_GRAALVM_FLAGS = true" >>"$tmp_env_file"
  fi
}
__epx-mc-get-backup-enabled() {
  local config_env="$1"
  local backup_enabled=$(__epx-mc-get-env-value "$config_env" "BACKUP")
  if [[ "${backup_enabled,,}" == "true" ]]; then
    echo "true"
  else
    echo "false"
  fi
}
__epx-mc() {
  local file_basename=$(basename -- "$1")
  file_basename="${file_basename%.env}"
  local server_type=$(echo "$file_basename" | awk -F'_' '{print $1}')
  local project_name="mc_$file_basename"
  local compose_file_base="$__epx_mc__compose_base/docker-compose.base.yml"
  local compose_file_full="$__epx_mc__compose_base/docker-compose.full.yml"
  local config_env="$__epx_mc__config_env_base/$file_basename.env"
  local java_type=$(__epx-mc-get-java-type "$config_env")
  local backup_enabled=$(__epx-mc-get-backup-enabled "$config_env")

  if [[ ! -f "$config_env" ]]; then
    echo "Error: Environment file $config_env does not exist."
    return 1
  fi

  # create a tmp env file with the JAVA_TYPE variable
  local tmp_env_file=$(mktemp)
  echo "SERVER_TYPE = $server_type" >>"$tmp_env_file"
  echo "SERVER_DIR = $__epx_mc__server_dir" >>"$tmp_env_file"
  echo "JAVA_TYPE = $java_type" >>"$tmp_env_file"
  __epx-mc-set-flags "$config_env" "$tmp_env_file"

  echo -e "Starting Minecraft Server"
  if [[ "$backup_enabled" == "true" ]]; then
    echo "BACKUP_DIR = $__epx_mc__backup_dir" >>"$tmp_env_file"
    echo -e "> Backup is enabled"
  else
    echo -e "> Backup is disabled"
  fi

  echo -e "> Environment Variables:"
  if [[ -s "$config_env" ]]; then
    grep -v '^[[:space:]]*#' "$config_env" | grep -E '^[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=' | while IFS= read -r line; do
      echo "  - $line"
    done
  else
    echo "  (No variables in $config_env)"
  fi
  if [[ -s "$tmp_env_file" ]]; then
    grep -v '^[[:space:]]*#' "$tmp_env_file" | grep -E '^[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=' | while IFS= read -r line; do
      echo "  - $line"
    done
  else
    echo "  (No variables in $tmp_env_file)"
  fi

  if [[ "$backup_enabled" == "true" ]]; then
    if [[ ! -f "$compose_file_full" ]]; then
      echo "Error: Docker Compose file $compose_file_full does not exist."
      return 1
    fi

    docker compose -p "$project_name" \
      --env-file "$tmp_env_file" \
      --env-file "$config_env" \
      -f "$compose_file_full" \
      up -d
  else
    if [[ ! -f "$compose_file_base" ]]; then
      echo "Error: Docker Compose file $compose_file_base does not exist."
      return 1
    fi

    docker compose -p "$project_name" \
      --env-file "$tmp_env_file" \
      --env-file "$config_env" \
      -f "$compose_file_base" \
      up -d
  fi

  # clean up the tmp env file
  rm -f "$tmp_env_file"
}

__epx-mc-get-configs() {
  find "$__epx_mc__config_env_base" -type f -name "*.env" -not \( -name "@*" \) -printf '%f\n' | sed 's/\.env$//'
}
__epx-mc-get-configs-examples() {
  find "$__epx_mc__config_env_base/examples" -type f -name "@*.env" -printf '%f\n' | sed 's/^@example.//' | sed 's/\.env$//'
}
__epx-mc-list-configs() {
  _autocomplete "$(__epx-mc-get-configs "$1")"
}
__epx-mc-list-configs-examples() {
  _autocomplete "$(__epx-mc-get-configs-examples "$1")"
}
__epx-mc-display-help() {
  echo "Usage: mc <server>"
  echo "Available servers:"
  __epx-mc-get-configs $1 | sed 's/^/  /'
}

mc() {
  if [[ -z "$1" ]]; then
    __epx-mc-display-help
    return 1
  fi

  __epx-mc "$1"
}
complete -F __epx-mc-list-configs mc

mc.install() {
  if [[ -z "$MINECRAFT_PROJECT_DIR" ]]; then
    echo "Error: MINECRAFT_PROJECT_DIR is not set in your configuration, please set it in your .config/minecraft.config file."
    return 1
  fi

  if ! command -v git &>/dev/null; then
    echo "Error: git is not installed. Please install git to run this command."
    return 1
  fi

  if ! git clone https://github.com/energypatrikhu/minecraft "$__epx_mc__project_base"; then
    echo "Error: Failed to clone the Minecraft repository."
    return 1
  fi

  echo "Minecraft project install completed successfully."
  echo "You can now configure your Minecraft servers."
  echo "To pull changes from git, use 'mc.update'."

  echo "Minecraft project directory is located at $__epx_mc__project_base"
  echo "Setup the curseforge api key in $__epx_mc__project_base/secrets/curseforge_api_key.txt"
  echo "Create a new server configuration file in $__epx_mc__config_env_base by copying the example files"

  echo "To show available servers and usage, use the command: mc"
  echo "To start a server, use the command: mc <server_name>"
  echo "To create a new server configuration file, use the command: mc.create <server_type>"
}

mc.update() {
  if [[ ! -d "$__epx_mc__project_base" ]]; then
    echo "Error: Minecraft project directory does not exist. Please run 'mc.setup' first."
    return 1
  fi

  if ! command -v git &>/dev/null; then
    echo "Error: git is not installed. Please install git to run this command."
    return 1
  fi

  cd "$__epx_mc__project_base" || exit
  if ! git pull; then
    echo "Error: Failed to update the Minecraft project."
    return 1
  fi

  echo "Minecraft project updated successfully."
}

mc.create() {
  local server_type="$1"
  local server_name="$2"

  if [[ -z "$server_type" ]]; then
    echo "Usage: mc.create <server_type> [server_name]"
    echo "Available server types:"
    __epx-mc-get-configs-examples | sed 's/^/  /'
    return 1
  fi

  local config_file="$__epx_mc__config_env_base/examples/@example.$server_type.env"
  if [[ ! -f "$config_file" ]]; then
    echo "Error: Configuration file for server type '$server_type' does not exist."
    echo "Available server types:"
    __epx-mc-get-configs-examples | sed 's/^/  /'
    return 1
  fi

  local date=$(date +%Y-%m-%d)
  local new_config_file="$__epx_mc__config_env_base/${server_type}_${date}_${server_name:-CHANGEME}.env"

  if [[ -f "$new_config_file" ]]; then
    echo "Error: Configuration file '$new_config_file' already exists. Please choose a different name."
    return 1
  fi

  touch "$new_config_file"
  while IFS= read -r line; do
    if [[ "$line" == "CREATED_AT = "* ]]; then
      line="CREATED_AT = $date"
    fi
    if [[ "$line" == "SERVER_NAME = "* ]]; then
      if [[ -n "$server_name" ]]; then
        line="SERVER_NAME = $server_name"
      else
        line="SERVER_NAME = CHANGE ME"
      fi
    fi

    echo "$line" >>"$new_config_file"
  done <"$config_file"

  echo "Configuration file '$new_config_file' created successfully."
  if [[ -n "$server_name" ]]; then
    echo "Please replace 'CHANGEME' in the filename with your desired server name or modpack name."
  fi
  echo "You can now edit the configuration file '$new_config_file' to set up your server."
}
complete -F __epx-mc-list-configs-examples mc.create

mc.help() {
  echo "+------------+--------------------------------------------------------+"
  echo "| mc.help    | Minecraft commands (This command)                      |"
  echo "+------------+--------------------------------------------------------+"
  echo "| mc         | Start Minecraft Server (mc <server>)                   |"
  echo "+------------+--------------------------------------------------------+"
  echo "| mc.create  | Create a new Minecraft server configuration file       |"
  echo "+------------+--------------------------------------------------------+"
  echo "| mc.install | Download required files for running a Minecraft server |"
  echo "+------------+--------------------------------------------------------+"
  echo "| mc.update  | Update Minecraft server files (mc.update)              |"
  echo "+------------+--------------------------------------------------------+"
}
