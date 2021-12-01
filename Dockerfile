FROM shivammathur/node:latest

ARG RUNNER_VERSION='2.284.0'
ARG ORG=foo
ARG ACCESS_TOKEN=tkn

RUN set -ex && apt-get update && apt-get install -y ca-certificates curl gnupg iputils-ping libicu-dev sudo jq --no-install-recommends

RUN adduser --disabled-password --gecos '' runner \
  && usermod -aG sudo runner \
  && mkdir -m 777 -p /home/runner \
  && sed -i 's/%sudo\s.*/%sudo ALL=(ALL:ALL) NOPASSWD : ALL/g' /etc/sudoers

WORKDIR /home/runner

COPY entrypoint.sh entrypoint.sh
RUN chmod 777 entrypoint.sh


COPY token.sh token.sh
RUN chmod 777 token.sh

USER runner

RUN sudo mkdir -p /opt/hostedtoolcache \
  && sudo chmod -R 777 /opt/hostedtoolcache

RUN sudo curl -o runner.tar.gz -sSL https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
  && sudo tar xf runner.tar.gz \
  && sudo bash ./bin/installdependencies.sh || true


ENTRYPOINT ["./entrypoint.sh"]
CMD ["./bin/Runner.Listener", "run", "--startuptype", "service"]

#CMD [ "bash", "-c", "./config.sh --url ${RUNNER_URL} --token ${RUNNER_TOKEN} --name runner --runnergroup Default --labels linux,self-hosted --work /tmp/runner; ./run.sh; sleep infinity"]
