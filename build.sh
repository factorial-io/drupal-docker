#!/bin/bash

# Build script to build all docker images.
#
# This script needs some more love.
set -e

# WHAT can be native, amd64, arm or both
# If both is set then the images are ushed to the registry


export WHAT=$1

if [ -z $2 ]
then
  export VERSIONS_TO_BUILD="74 80 81 82 83"
else
  export VERSIONS_TO_BUILD="$2"
fi

if [ -z $3 ]
then
  export SUFFiX=""
else
  export SUFFIX="-$3"
fi


case $WHAT in
  native)
    export BUILD_CMD="docker build "
    ;;

  amd64)
    export PLATFORMS=linux/amd64
    export BUILD_CMD="docker buildx build --push "
    ;;

  arm64)
    export PLATFORMS=linux/arm64
    export BUILD_CMD="docker buildx build --push "
    ;;

  both)
    export PLATFORMS=linux/amd64,linux/arm64
    export BUILD_CMD="docker buildx build --push --platform $PLATFORMS"
    ;;

  *)
    echo "Unknown what, should be native, amd64, arm64 or both."
    echo "Run:"
    echo "./build.sh <native|amd64|arm64|both> <versions-separated-by-spaces> <suffix>"
    echo ""
    echo "Example ./build.sh native 80 test, this will build php8.0 and tag it with test-suffix"
    exit
    ;;
esac


function build_and_push_image() {
  local php_version=$1
  local base_image_tag=$2
  local tag=$3

  echo -e "\n\n\n--------"
  echo "Building php $php_version with suffix $suffix and tag it with $tag ..."
  echo -e "--------\n\n\n"

  $BUILD_CMD \
    --build-arg BASE_IMAGE_TAG=$base_image_tag \
    -t factorial/drupal-docker:$tag \
    -f Dockerfile.php-$php_version \
    .
}

function build_node_and_push_image() {
  local php_version=$1
  local base_image_tag=$2
  local suffix=$3
  local node_versions=("12" "14" "16")
  for node_version in "${node_versions[@]}"
  do
    local tag=php-$php_version-node-$node_version$suffix

    echo -e "\n\n\n--------"
    echo "Building node $node_version together with php $php_version with suffix $suffix and tag it with $tag ..."
    echo -e "--------\n\n\n"

    $BUILD_CMD \
      --build-arg BASE_IMAGE_TAG=$base_image_tag \
      --build-arg NODE_VERSION=$node_version \
      -t factorial/drupal-docker:$tag \
      -f Dockerfile.php-$php_version \
      .
  done

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
   cd ../php-node

   build_node_and_push_image $php_version php-$1$suffix $suffix
}


for version in $VERSIONS_TO_BUILD; do
  build_version $version $SUFFIX
done
