if ! command -v fish &> /dev/null; then
  echo -e "[$(_c LIGHT_BLUE "Fish Setup")] Installing Fish shell..."

  if command -v apt-get &> /dev/null; then
    echo -e "[$(_c LIGHT_BLUE "Fish Setup")] Detected $(_c LIGHT_YELLOW "apt-get") package manager"
    sudo apt-get update
    sudo apt-get install -y fish
  elif command -v brew &> /dev/null; then
    echo -e "[$(_c LIGHT_BLUE "Fish Setup")] Detected $(_c LIGHT_YELLOW "brew") package manager"
    brew install fish
  elif command -v yum &> /dev/null; then
    echo -e "[$(_c LIGHT_BLUE "Fish Setup")] Detected $(_c LIGHT_YELLOW "yum") package manager"
    sudo yum install -y fish
  elif command -v pacman &> /dev/null; then
    echo -e "[$(_c LIGHT_BLUE "Fish Setup")] Detected $(_c LIGHT_YELLOW "pacman") package manager"
    sudo pacman -S --noconfirm fish
  else
    echo -e "[$(_c LIGHT_BLUE "Fish Setup")] $(_c LIGHT_RED "Error"): Unsupported package manager"
    echo -e "[$(_c LIGHT_BLUE "Fish Setup")] Please install Fish shell manually"
    exit 1
  fi

  if [[ $? -eq 0 ]]; then
    echo -e "[$(_c LIGHT_BLUE "Fish Setup")] $(_c LIGHT_GREEN "Fish shell installed successfully")"
  else
    echo -e "[$(_c LIGHT_BLUE "Fish Setup")] $(_c LIGHT_RED "Failed to install Fish shell")"
    exit 1
  fi
else
  echo -e "[$(_c LIGHT_BLUE "Fish Setup")] Fish shell already installed"
fi

FISH_PATH=$(command -v fish)
echo -e "[$(_c LIGHT_BLUE "Fish Setup")] Fish path: $(_c LIGHT_YELLOW "$FISH_PATH")"

echo -e "[$(_c LIGHT_BLUE "Fish Setup")] Setting Fish as default shell for all users..."
while IFS=: read -r username _ uid _ _ home _; do
  if [ "$uid" -ge 1000 ] 2>/dev/null || [ "$username" = "root" ]; then
    echo -e "[$(_c LIGHT_BLUE "Fish Setup")] Configuring user: $(_c LIGHT_YELLOW "$username")"
    sudo chsh -s "$FISH_PATH" "$username"
  fi
done < /etc/passwd

echo -e "[$(_c LIGHT_BLUE "Fish Setup")] $(_c LIGHT_GREEN "Fish shell setup completed")"
