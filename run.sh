#!/bin/bash

function help {
  echo "Usage: run.sh <project-name> <path-to-your-project-root> [--webRoot <path-to-your-drupal-root>] [--http <public-http-port>] [--ssh <public-ssh-port>] [--vhost <vhost>] [--rebuild]"
}

if [ "$#" -lt 2 ]; then
  help
fi

CONTAINER_NAME=$1
IMAGE_NAME=${CONTAINER_NAME}/latest
DATA_CONTAINER_NAME=${CONTAINER_NAME}_mysql_data
ROOT_PATH=$2
WEB_ROOT=$2
DOCKER=/usr/bin/docker

# remove 2
shift
shift

while test $# -gt 0
do
  case $1 in

  # Normal option processing
    -h|--http)
      PUBLIC_HTTP_PORT=$2
      shift
      ;;
    -s|--ssh)
      PUBLIC_SSH_PORT=$2
      shift
      ;;
    -v|--vhost)
      VHOST=$2
      shift
      ;;
    -w|--webRoot)
      WEB_ROOT=$2
      shift
      ;;
    -r|--rebuild)
      REBUILD=1
      shift
      ;;
  # ...

  # Special cases
    --)
      ;;
    --*)
      # error unknown (long) option $1
      help
      echo "unknown option: $1"
      ;;
    -?)
      # error unknown (short) option $1
      help
      echo "unknown option: $1"

      ;;

    -*)
      split=$1
      shift
      set -- $(echo "$split" | cut -c 2- | sed 's/./-& /g') "$@"
      continue
      ;;

  # Done with options
    *)
      break
      ;;
  esac
  shift
done

ARGUMENTS=""
if [ -n "${PUBLIC_HTTP_PORT}" ]; then
  ARGUMENTS="${ARGUMENTS} -p ${PUBLIC_HTTP_PORT}:80"
fi

if [ -n "${PUBLIC_SSH_PORT}" ]; then
  ARGUMENTS="${ARGUMENTS} -p ${PUBLIC_SSH_PORT}:22"
fi

if [ -n "${VHOST}" ]; then
  ARGUMENTS="${ARGUMENTS} -e VHOST=${VHOST}"
fi

ARGUMENTS="-e WEB_ROOT=${WEB_ROOT} ${ARGUMENTS}"

echo "running ${CONTAINER_NAME} from ${ROOT_PATH} with ${ARGUMENTS}"

# run storage container
${DOCKER} stop ${CONTAINER_NAME} >> /dev/null
${DOCKER} rm ${CONTAINER_NAME} >> /dev/null

# check datacontainer
if ${DOCKER} ps -a | grep -qw ${DATA_CONTAINER_NAME}
then
  echo "${DATA_CONTAINER_NAME} already exists. do not build. \n"
else
  echo "datacontainer ${DATA_CONTAINER_NAME} does not exist. building now... \n"
  ${DOCKER} run -d --name ${DATA_CONTAINER_NAME} -v /var/lib/mysql busybox /bin/sh
fi

#check image
if  ${DOCKER} images | grep -qw ${IMAGE_NAME}  && [ ${REBUILD} != 1 ]
then
  echo "image ${IMAGE_NAME} already exists. do not build. \n"
else
  echo "image ${IMAGE_NAME} does not exist. building now... \n"
  ${DOCKER} build -t ${IMAGE_NAME} ./docker
fi


# start our container
${DOCKER} run -d --volumes-from ${DATA_CONTAINER_NAME}  -e PROJECT_NAME=${CONTAINER_NAME} --name ${CONTAINER_NAME} ${ARGUMENTS} -v ${ROOT_PATH}:/var/www ${IMAGE_NAME}
${DOCKER} run --rm -v /usr/local/bin:/target jpetazzo/nsenter
