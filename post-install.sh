#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
  set -o xtrace
fi

# Setup environment
PROFILE_DIR="/etc/profile.d"
ENV_FILE="/etc/environment"

if [[ -z "${EPX_HOME-}" ]]; then
  export EPX_HOME="/usr/local/epx"
fi

if [[ -f "${ENV_FILE}" ]]; then
  if ! grep -Fq "EPX_HOME" "${ENV_FILE}"; then
    echo "EPX_HOME=\"${EPX_HOME}\"" >> "${ENV_FILE}"
    echo "Added EPX_HOME to ${ENV_FILE}"
  fi
fi

# Add EPX_HOME and source epx.sh to the profile.d script
EPX_BIN="${PROFILE_DIR}/00-epx.sh"
EPX_FISH_CONFIG="${HOME}/.config/fish/conf.d/00-epx.fish"

# Setup for bash/sh shells
if [[ ! -f "${EPX_BIN}" ]]; then
  echo "Creating ${EPX_BIN}"
  echo "#!/usr/bin/env bash" > "${EPX_BIN}"

  if [[ ! -f "${ENV_FILE}" ]]; then
    echo "export EPX_HOME=\"${EPX_HOME}\"" >> "${EPX_BIN}"
  fi

  echo "source \"\${EPX_HOME}/aliases.sh\"" >> "${EPX_BIN}"
  echo "source \"\${EPX_HOME}/autoscripts.sh\"" >> "${EPX_BIN}"
  echo "source \"\${EPX_HOME}/autocomplete.sh\"" >> "${EPX_BIN}"
else
  echo "${EPX_BIN} already exists, checking content..."

  if [[ ! -f "${ENV_FILE}" ]]; then
    if ! grep -Fq "EPX_HOME" "${EPX_BIN}"; then
      echo "export EPX_HOME=\"${EPX_HOME}\"" >> "${EPX_BIN}"
      echo "${ENV_FILE} not found, added missing EPX_HOME to ${EPX_BIN}"
    fi
  fi

  if ! grep -Fq "aliases.sh" "${EPX_BIN}"; then
    echo "source \"\${EPX_HOME}/aliases.sh\"" >> "${EPX_BIN}"
    echo "Added missing aliases.sh to ${EPX_BIN}"
  fi

  if ! grep -Fq "autoscripts.sh" "${EPX_BIN}"; then
    echo "source \"\${EPX_HOME}/autoscripts.sh\"" >> "${EPX_BIN}"
    echo "Added missing autoscripts.sh to ${EPX_BIN}"
  fi

  if ! grep -Fq "autocomplete.sh" "${EPX_BIN}"; then
    echo "source \"\${EPX_HOME}/autocomplete.sh\"" >> "${EPX_BIN}"
    echo "Added missing autocomplete.sh to ${EPX_BIN}"
  fi
fi

# Setup for fish shell
if command -v fish &> /dev/null; then
  echo "Detected fish shell, setting up fish configuration..."

  # Create fish config directory if it doesn't exist
  mkdir -p "$(dirname "${EPX_FISH_CONFIG}")"

  if [[ ! -f "${EPX_FISH_CONFIG}" ]]; then
    echo "Creating ${EPX_FISH_CONFIG}"
    cat > "${EPX_FISH_CONFIG}" << 'EOF'
# EPX Environment Setup for Fish Shell
set -gx EPX_HOME "/usr/local/epx"

# Source EPX aliases for fish
if test -f "$EPX_HOME/aliases.fish"
  source "$EPX_HOME/aliases.fish"
end

# Source EPX autocomplete for fish
if test -f "$EPX_HOME/autocomplete.fish"
  source "$EPX_HOME/autocomplete.fish"
end
EOF
    echo "Fish configuration created at ${EPX_FISH_CONFIG}"
  else
    echo "${EPX_FISH_CONFIG} already exists"

    if ! grep -Fq "EPX_HOME" "${EPX_FISH_CONFIG}"; then
      echo 'set -gx EPX_HOME "/usr/local/epx"' >> "${EPX_FISH_CONFIG}"
      echo "Added EPX_HOME to ${EPX_FISH_CONFIG}"
    fi

    if ! grep -Fq "aliases.fish" "${EPX_FISH_CONFIG}"; then
      cat >> "${EPX_FISH_CONFIG}" << 'EOF'

# Source EPX aliases for fish
if test -f "$EPX_HOME/aliases.fish"
  source "$EPX_HOME/aliases.fish"
end
EOF
      echo "Added aliases.fish to ${EPX_FISH_CONFIG}"
    fi

    if ! grep -Fq "autocomplete.fish" "${EPX_FISH_CONFIG}"; then
      cat >> "${EPX_FISH_CONFIG}" << 'EOF'

# Source EPX autocomplete for fish
if test -f "$EPX_HOME/autocomplete.fish"
  source "$EPX_HOME/autocomplete.fish"
end
EOF
      echo "Added autocomplete.fish to ${EPX_FISH_CONFIG}"
    fi
  fi
fi

# Setup crontab for epx self-update
CRON_FILE="/etc/cron.daily/epx-self-update"
CRON_JOB="#!/bin/sh
/usr/local/bin/epx self-update"

if [[ ! -f "${CRON_FILE}" ]]; then
  echo "Creating ${CRON_FILE}"
  echo "${CRON_JOB}" > "${CRON_FILE}"
  sudo chmod +x "${CRON_FILE}"
else
  echo "${CRON_FILE} already exists, checking content..."
  if ! cmp -s "${CRON_FILE}" <(echo "${CRON_JOB}"); then
    echo "${CRON_JOB}" > "${CRON_FILE}"
    echo "Fixed ${CRON_FILE} content"
  fi
fi

# Run linking script if it exists
if [[ -f "${EPX_HOME}/link.sh" ]]; then
  echo "Running linking script..."
  "${EPX_HOME}/link.sh"
else
  echo "Linking script not found, skipping."
fi

echo "EPX setup complete, please restart your terminal to apply changes."
