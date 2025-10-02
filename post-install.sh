#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
  set -o xtrace
fi

# Setup environment
export PROFILE_DIR="/etc/profile.d"
export ENV_FILE="/etc/environment"

if [[ -z "${EPX_HOME-}" ]]; then
  export EPX_HOME="/usr/local/epx"
fi

if [[ -f "${ENV_FILE}" ]]; then
  if ! grep -Fxq "EPX_HOME" "${ENV_FILE}"; then
    echo "Adding EPX_HOME to ${ENV_FILE}"
    echo "EPX_HOME=\"${EPX_HOME}\"" | sudo tee -a "${ENV_FILE}" >/dev/null
  else
    echo "EPX_HOME already exists in ${ENV_FILE}, checking content..."

    if ! grep -Fxq "EPX_HOME" "${ENV_FILE}"; then
      echo "EPX_HOME=\"${EPX_HOME}\"" | sudo tee -a "${ENV_FILE}" >/dev/null
      echo "Added EPX_HOME to ${ENV_FILE}"
    fi
  fi
fi

# Add EPX_HOME and source epx.sh to the profile.d script
export EPX_BIN="${PROFILE_DIR}/00-epx.sh"
if [[ ! -f "${EPX_BIN}" ]]; then
  echo "Creating ${EPX_BIN}"
  echo "#!/bin/bash" | sudo tee "${EPX_BIN}" >/dev/null

  if [[ ! -f "${ENV_FILE}" ]]; then
    echo "export EPX_HOME=\"${EPX_HOME}\"" | sudo tee -a "${EPX_BIN}" >/dev/null
  fi

  echo "source \"\${EPX_HOME}/aliases.sh\"" | sudo tee -a "${EPX_BIN}" >/dev/null
  echo "source \"\${EPX_HOME}/autoscripts.sh\"" | sudo tee -a "${EPX_BIN}" >/dev/null
  echo "source \"\${EPX_HOME}/autocomplete.sh\"" | sudo tee -a "${EPX_BIN}" >/dev/null
else
  echo "${EPX_BIN} already exists, checking content..."

  if ! grep -Fxq "aliases.sh" "${EPX_BIN}"; then
    echo "source \"\${EPX_HOME}/aliases.sh\"" | sudo tee -a "${EPX_BIN}" >/dev/null
    echo "Added aliases.sh to ${EPX_BIN}"
  fi

  if ! grep -Fxq "autoscripts.sh" "${EPX_BIN}"; then
    echo "source \"\${EPX_HOME}/autoscripts.sh\"" | sudo tee -a "${EPX_BIN}" >/dev/null
    echo "Added autoscripts.sh to ${EPX_BIN}"
  fi

  if ! grep -Fxq "autocomplete.sh" "${EPX_BIN}"; then
    echo "source \"\${EPX_HOME}/autocomplete.sh\"" | sudo tee -a "${EPX_BIN}" >/dev/null
    echo "Added autocomplete.sh to ${EPX_BIN}"
  fi
fi

# Setup crontab for epx self-update
export CRON_FILE="/etc/cron.daily/epx-self-update"
export CRON_JOB=$(cat <<EOF
#!/bin/sh
/usr/local/bin/epx self-update
EOF
)

if [[ ! -f "${CRON_FILE}" ]]; then
  echo "Creating ${CRON_FILE}"
  echo "${CRON_JOB}" | sudo tee -a "${CRON_FILE}" >/dev/null
  sudo chmod +x "${CRON_FILE}"
  echo "Added self-update job to ${CRON_FILE}"
else
  echo "${CRON_FILE} already exists, checking content..."
  if ! grep -Fxq "${CRON_JOB}" "${CRON_FILE}"; then
    echo "${CRON_JOB}" | sudo tee -a "${CRON_FILE}" >/dev/null
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
