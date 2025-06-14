#!/bin/bash

# Build all commands into the bin directory as extensionless executables
set -e

BIN_DIR="$(dirname "$0")/bin"
mkdir -p "$BIN_DIR"

# Find all .sh files in commands (recursively)
find "$(dirname "$0")/commands" -type f -name '*.sh' | while read -r file; do
  # Get the filename without extension and directory
  base="$(basename "$file" .sh)"
  # Skip files that start with an underscore
  if [[ "$base" == _* ]]; then
    continue
  fi
  # Extract all function names that do not start with _
  grep -E '^[a-zA-Z0-9_.]+\(\) *\{' "$file" |
    grep -vE '^_' |
    sed -E 's/\(\) *\{.*$//' | while read -r func; do
    # Remove dots from function name for filename
    bin_path="$BIN_DIR/$func"
    # Create the bin file
    cat >"$bin_path" <<EOF
#!/bin/bash
. "$(dirname "$0")/../$file"
$func "\$@"
EOF
    chmod +x "$bin_path"
  done
done

# Also build epx.sh as an extensionless executable in bin
EPX_SRC="$(dirname "$0")/epx.sh"
EPX_BIN="$BIN_DIR/epx"
cat >"$EPX_BIN" <<EOF
#!/bin/bash
. "$EPX_SRC"
epx "\$@"
EOF
chmod +x "$EPX_BIN"

echo "All commands built into $BIN_DIR."

# Add the bin directory to PATH if not already present using profile.d script
PROFILE_DIR="/etc/profile.d"
PROFILE_SCRIPT="$PROFILE_DIR/epx_bin.sh"
if [[ ! -f "$PROFILE_SCRIPT" ]]; then
  echo "Adding $BIN_DIR to PATH in $PROFILE_SCRIPT"
  echo "export PATH=\"\$BIN_DIR:$PATH\"" | sudo tee "$PROFILE_SCRIPT" >/dev/null
else
  echo "$BIN_DIR is already in PATH."
fi

# Add aliases.sh to profile.d if it doesn't exist
ALIAS_SCRIPT="$PROFILE_DIR/epx_aliases.sh"
if [[ ! -f "$ALIAS_SCRIPT" ]]; then
  echo "Adding aliases to $ALIAS_SCRIPT"
  echo "source $(dirname "$0")/aliases.sh" | sudo tee "$ALIAS_SCRIPT" >/dev/null
else
  echo "Aliases already exist in $ALIAS_SCRIPT."
fi
