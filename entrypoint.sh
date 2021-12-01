#!/bin/bash

export -n ACCESS_TOKEN
_RUNNER_URL=https://github.com/${ORG}
_RUNNER_NAME_PREFIX=${RUNNER_NAME_PREFIX:-"runner"}
_RUNNER_WORKDIR=${RUNNER_WORKDIR:-"/tmp/runner"}
_LABELS=${LABELS:-"linux,self-hosted"}


deregister_runner() {
  echo "Caught SIGTERM. Deregistering runner"
  echo "Obtaining the token of the runner"
  if [[ -n "${ACCESS_TOKEN}" ]]; then
    _TOKEN=$(ACCESS_TOKEN="${ACCESS_TOKEN}" bash /home/runner/token.sh)
    RUNNER_TOKEN=$(echo "${_TOKEN}" | jq -r .token)
  fi
  ./config.sh remove --token "${RUNNER_TOKEN}"
  exit
}

_RUNNER_NAME=${RUNNER_NAME:-${_RUNNER_NAME_PREFIX:-github-runner}-$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')}

configure_runner(){
  if [[ -n "${ACCESS_TOKEN}" ]]; then
    echo "Obtaining the token of the runner"
    _TOKEN=$(ACCESS_TOKEN="${ACCESS_TOKEN}" bash /home/runner/token.sh)
    echo ${_TOKEN}
    RUNNER_TOKEN=$(echo "${_TOKEN}" | jq -r .token)
    echo ${RUNNER_TOKEN}
    echo "done"
  fi

  echo "Configuring"
    ./config.sh \
        --url "${_RUNNER_URL}" \
        --token "${RUNNER_TOKEN}" \
        --name "${_RUNNER_NAME}" \
        --work "${_RUNNER_WORKDIR}" \
        --labels "${_LABELS}" \
        --runnergroup "Default" \
        --unattended \
        --replace ${_EPHEMERAL}
}

configure_runner

trap deregister_runner SIGINT SIGQUIT SIGTERM INT TERM QUIT

"${@}" &

wait $!
