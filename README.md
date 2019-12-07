# Dockerfiles for drupal

This repository contains dockerfiles for various php versions, together with apache, ssh and tools useful for debugging. They are not meant to be used for production hosting.

The docker container comes with 2 services, apache on 80 and ssh on 22. You will need to map your local installation to /var/www.

## Logins / Passwords

    ssh    : root:root

The container contains

  * apache 2
  * php with some extensions
  * composer
  * ssh
  * git
  * imagemagick

## Building the docker container:

```
docker build -t factorial/drupal-docker:php<version>  -f Dockerfile.php-<version> .
```



