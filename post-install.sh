#!/bin/bash

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
if [[ ! -f "${EPX_BIN}" ]]; then
  echo "Creating ${EPX_BIN}"
  echo "#!/bin/bash" > "${EPX_BIN}"

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
  if ! grep -Fq "${CRON_JOB}" "${CRON_FILE}"; then
    echo "${CRON_JOB}" >> "${CRON_FILE}"
    echo "Fixed ${CRON_FILE} to include self-update job"
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
