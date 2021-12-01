#!/bin/bash

export RUNNER_URL=https://github.com/${ORG}
export -n ACCESS_TOKEN
export RUNNER_NAME_PREFIX=runner
export RUNNER_WORKDIR=/tmp/runner
export LABELS="linux,self-hosted"

deregister_runner() {
  echo "Caught SIGTERM. Deregistering runner"
  if [[ -n "${ACCESS_TOKEN}" ]]; then
    _TOKEN=$(ACCESS_TOKEN="${ACCESS_TOKEN}" bash /home/runner/token.sh)
    RUNNER_TOKEN=$(echo "${_TOKEN}" | jq -r .token)
  fi
  ./config.sh remove --token "${RUNNER_TOKEN}"
  exit
}

_RUNNER_NAME=${RUNNER_NAME:-${RUNNER_NAME_PREFIX:-github-runner}-$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')}

configure_runner(){
  if [[ -n "${ACCESS_TOKEN}" ]]; then
    echo "Obtaining the token of the runner"
    _TOKEN=$(ACCESS_TOKEN="${ACCESS_TOKEN}" bash /home/runner/token.sh)
    RUNNER_TOKEN=$(echo "${_TOKEN}" | jq -r .token)
  fi

  echo "Configuring"
    ./config.sh \
        --url "${RUNNER_URL}" \
        --token "${RUNNER_TOKEN}" \
        --name "${_RUNNER_NAME}" \
        --work "${RUNNER_WORKDIR}" \
        --labels "${LABELS}" \
        --runnergroup "Default" \
        --unattended \
        --replace
}

configure_runner

trap deregister_runner SIGINT SIGQUIT SIGTERM INT TERM QUIT

"$@"
