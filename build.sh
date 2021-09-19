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

if [ -z $2 ]
then
  export SUFFiX=""
else
  export SUFFIX="-$2"
fi

if [ -z $3 ]
then
  export VERSIONS_TO_BUILD="71 72 73 74 80"
else
  export VERSIONS_TO_BUILD="$3"
fi

case $WHAT in
  native)
    export BUILD_CMD="docker build --build-arg TARGETARCH=$TARGETARCH"
    ;;

  amd64)
    export PLATFORMS=linux/amd64
    export BUILD_CMD="docker buildx build --push --platform $PLATFORMS"
    ;;

  arm64)
    export PLATFORMS=linux/arm64
    export BUILD_CMD="docker buildx build --push --platform $PLATFORMS"
    ;;

  both)
    export PLATFORMS=linux/amd64,linux/arm64
    export BUILD_CMD="docker buildx build --push --platform $PLATFORMS"
    ;;

  *)
    echo "Unknown what, should be native, amd64, arm64 or both."
    echo "Run:"
    echo "./build.sh <native|amd64|arm64|both> <suffix> <versions-separated-by-spaces>"
    echo ""
    echo "Example ./build.sh native test 80, this will build php8.0 and tag it with test-suffix"
    exit
    ;;
esac


function build_and_push_image() {
  local php_version=$1
  local base_image_tag=$2
  local tag=$3

  echo "--------"
  echo "Building php $php_version with suffix $suffix and tag it with $tag ..."
  echo "--------"

  $BUILD_CMD \
    --build-arg BASE_IMAGE_TAG=$base_image_tag \
    -t factorial/drupal-docker:$tag \
    -f Dockerfile.php-$php_version \
    .
}

function build_version() {
  local php_version=$1
  local suffix=$2
  echo "Building $php_version and tagging it with suffix $suffix"

   cd php
   build_and_push_image $php_version php-$1 php-$1$suffix
   cd ../php-xdebug
   build_and_push_image $php_version php-$1$suffix php-$php_version-xdebug$suffix
   cd ../php-wkhtmltopdf
   build_and_push_image $php_version php-$1$suffix php-$php_version-wkhtmltopdf$suffix
   cd ..
}


for version in $VERSIONS_TO_BUILD; do
  build_version $version $SUFFIX
done
