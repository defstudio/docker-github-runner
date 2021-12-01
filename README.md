# Docker github runner

This package is optimized to execute [shivammathur/setup-php](https://github.com/shivammathur/setup-php) action in a docker self-hosted runner

## Setup

- create a new `docker-compose.yml` file

```yml
version: '3.5'

services:
  runner:
    image: defstudio/github-runner:latest
    restart: unless-stopped
    environment:
      ACCESS_TOKEN: "${ACCESS_TOKEN}"
      RUNNER_NAME_PREFIX: "${RUNNER_NAME_PREFIX}"
      ORG: "${ORG_NAME}"
      LABELS: "${LABELS}"
    security_opt:
      - label:disable
    volumes:
      - '/var/run/docker.sock:/var/run/docker.sock'
```

- add an `.env` file to store settings

```dotenv
ACCESS_TOKEN=<TOKEN>
RUNNER_NAME_PREFIX=runner
ORG_NAME=def-studio
LABELS=linux,self-hosted
```

## Starting new runners

#### Single runner

```shell
docker-compose up -d
```

#### Multiple runners

```shell
docker-compose up -d --scale runner=5
```

## Credits

- [Fabio Ivona](https://github.com/def-studio)
- [myoung34/docker-github-actions-runner](https://github.com/myoung34/docker-github-actions-runner)
- [https://github.com/shivammathur/setup-php](https://github.com/shivammathur/setup-php)
- [All Contributors](../../contributors)

Please see the [contributing guide](https://def-studio.github.io/pest-plugin-laravel-expectations/developers/contribute) for details on how to contribute to this plugin.

## Security Vulnerabilities

Please review [our security policy](../../security/policy) on how to report security vulnerabilities.

## License

The MIT License (MIT). Please see [License File](LICENSE.md) for more information.
