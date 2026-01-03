if ! command -v micro &> /dev/null; then
  echo -e "[$(_c LIGHT_BLUE "Micro Setup")] Installing micro editor..."
  if command -v brew &>/dev/null; then
    echo -e "[$(_c LIGHT_BLUE "Micro Setup")] Detected $(_c LIGHT_YELLOW "brew") package manager"
    brew install micro
  elif command -v apt-get &>/dev/null; then
    echo -e "[$(_c LIGHT_BLUE "Micro Setup")] Detected $(_c LIGHT_YELLOW "apt-get") package manager"
    sudo apt-get update && sudo apt-get install -y micro
  elif command -v yum &>/dev/null; then
    echo -e "[$(_c LIGHT_BLUE "Micro Setup")] Detected $(_c LIGHT_YELLOW "yum") package manager"
    sudo yum install -y micro
  else
    echo -e "[$(_c LIGHT_BLUE "Micro Setup")] $(_c LIGHT_RED "Error"): Could not find package manager to install micro"
    return 1
  fi

  if [[ $? -eq 0 ]]; then
    echo -e "[$(_c LIGHT_BLUE "Micro Setup")] $(_c LIGHT_GREEN "Micro editor installed successfully")"
  else
    echo -e "[$(_c LIGHT_BLUE "Micro Setup")] $(_c LIGHT_RED "Failed to install micro editor")"
    return 1
  fi
else
  echo -e "[$(_c LIGHT_BLUE "Micro Setup")] Micro is already installed!"
fi

echo -e "[$(_c LIGHT_BLUE "Micro Setup")] Installing micro plugins..."
plugins=("aspell" "detectindent" "quoter")
for plugin in "${plugins[@]}"; do
  echo -e "[$(_c LIGHT_BLUE "Micro Setup")] Installing plugin: $(_c LIGHT_YELLOW "$plugin")"
  micro -plugin install "$plugin" || echo -e "[$(_c LIGHT_BLUE "Micro Setup")] $(_c LIGHT_YELLOW "Warning"): Failed to install $plugin plugin"
done

echo -e "[$(_c LIGHT_BLUE "Micro Setup")] $(_c LIGHT_GREEN "Micro setup completed")"
