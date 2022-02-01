FROM shivammathur/node:latest

LABEL maintainer="fabio.ivona@defstudio.it"


ARG RUNNER_VERSION='2.287.1'
ARG ORG=foo
ARG ACCESS_TOKEN=tkn

ARG DOCKER_KEY="7EA0A9C3F273FCD8"
ENV DOCKER_COMPOSE_VERSION="1.27.4"

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    software-properties-common \
    ca-certificates  \
    curl  \
    gnupg  \
    iputils-ping  \
    libicu-dev  \
    sudo  \
    jq
RUN cd / \
    # Determine the Distro name (Debian, Ubuntu, etc)
    && distro=$(lsb_release -is | awk '{print tolower($0)}') \
    # Determine the Distro version (bullseye, xenial, etc)
    # Note: sid is aliased to bullseye, because Docker doesn't have a matching apt repo
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ${DOCKER_KEY} \
    && curl -fsSL https://download.docker.com/linux/${distro}/gpg | apt-key add - \
    && version=$(lsb_release -cs | awk '{gsub("sid", "bullseye"); print $0}') \
    && ( add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/${distro} ${version} stable" ) \
    && apt-get update \
    && apt-get install -y docker-ce docker-ce-cli containerd.io --no-install-recommends --allow-unauthenticated \
    && [[ $(lscpu -J | jq -r '.lscpu[] | select(.field == "Vendor ID:") | .data') == "ARM" ]] && echo "Not installing docker-compose. See https://github.com/docker/compose/issues/6831" || ( curl -sL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose ) \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

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
