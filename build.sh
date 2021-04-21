#!/bin/bash

# Build script to build all docker images.
#
# This script needs some more love.
set -e

# WHAT can be native, amd64, arm or both
# If both is set then the images are ushed to the registry

case `uname -m` in
  arm64)
    export TARGETARCH=arm64
    ;;

  *)
    export TARGETARCH=amd64
    ;;

esac

export WHAT=$1

case $WHAT in
  native)
    export BUILD_CMD="docker build --build-arg TARGETARCH=$TARGETARCH"
    ;;

  amd64)
    export PLATFORMS=linux/amd64
    export BUILD_CMD="docker buildx build --load --platform $PLATFORMS"
    ;;

  arm64)
    export PLATFORMS=linux/arm64
    export BUILD_CMD="docker buildx build --load --platform $PLATFORMS"
    ;;

  both)
    export PLATFORMS=linux/amd64,linux/arm64
    export BUILD_CMD="docker buildx build --push --platform $PLATFORMS"
    ;;

  *)
    echo "Unknown what, should be native, amd64, arm64 or both."
    exit
    ;;
esac

function build_and_push_image() {
  echo "Building docker image $2 ..."
  $BUILD_CMD -t factorial/drupal-docker:$2 -f Dockerfile.php-$1 .
}

function build_version() {
  cd php
  build_and_push_image $1 php-$1
  cd ../php-xdebug
  build_and_push_image $1 php-$1-xdebug
  cd ../php-wkhtmltopdf
  build_and_push_image $1 php-$1-wkhtmltopdf
  cd ..
}

build_version "71"
build_version "72"
build_version "73"
build_version "74"
build_version "80"
