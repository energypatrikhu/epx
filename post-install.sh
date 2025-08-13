#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
  set -o xtrace
fi

# Setup environment
export PROFILE_DIR="/etc/profile.d"
export ENV_FILE="/etc/environment"

if [[ -z "${EPX_HOME}" ]]; then
  export EPX_HOME="/usr/local/epx"
fi

if [[ -f "${ENV_FILE}" ]]; then
  if ! grep -qF "EPX_HOME" "${ENV_FILE}"; then
    echo "Adding EPX_HOME to ${ENV_FILE}"
    echo "EPX_HOME=\"${EPX_HOME}\"" | sudo tee -a "${ENV_FILE}" >/dev/null
  else
    echo "EPX_HOME already exists in ${ENV_FILE}, skipping addition."
  fi
fi

# Add EPX_HOME and source epx.sh to the profile.d script
export EPX_BIN="${PROFILE_DIR}/00-epx.sh"
if [[ ! -f "${EPX_BIN}" ]]; then
  echo "Creating ${EPX_BIN}"
  echo "#!/usr/bin/env bash" | sudo tee "${EPX_BIN}" >/dev/null

  if [[ ! -f "${ENV_FILE}" ]]; then
    echo "export EPX_HOME=\"${EPX_HOME}\"" | sudo tee -a "${EPX_BIN}" >/dev/null
  fi

  echo "source \"\${EPX_HOME}/aliases.sh\"" | sudo tee -a "${EPX_BIN}" >/dev/null
  echo "source \"\${EPX_HOME}/autoscripts.sh\"" | sudo tee -a "${EPX_BIN}" >/dev/null
  echo "source \"\${EPX_HOME}/autocomplete.sh\"" | sudo tee -a "${EPX_BIN}" >/dev/null
else
  echo "${EPX_BIN} already exists, skipping creation."
fi

# Setup crontab for epx self-update
export CRON_FILE="/etc/cron.daily/epx-self-update"
export CRON_JOB="epx self-update"
if ! grep -qF "${CRON_JOB}" "${CRON_FILE}"; then
  echo "Adding self-update cron job to ${CRON_FILE}"
  echo "#!/usr/bin/env sh" | sudo tee "${CRON_FILE}" >/dev/null
  echo "source ${EPX_BIN}" | sudo tee -a "${CRON_FILE}" >/dev/null
  echo "epx self-update" | sudo tee -a "${CRON_FILE}" >/dev/null
else
  echo "Self-update cron job already exists in ${CRON_FILE}, skipping addition."
fi

# Run linking script if it exists
if [[ -f "${EPX_HOME}/link.sh" ]]; then
  echo "Running linking script..."
  "${EPX_HOME}/link.sh"
else
  echo "Linking script not found, skipping."
fi

echo "EPX setup complete, please restart your terminal to apply changes."
