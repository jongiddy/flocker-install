#!/bin/bash

docker ps > /dev/null 2>&1
if [ $? -eq 0 ]; then
    DOCKER=docker
else
    # assume failure was due to permissions
    DOCKER='sudo docker'
fi

set -e
set -a  # Variables from sourced files are exported to Vagrant commands

TOP=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

source read_server_args.sh "$0" "$@"

# Replace first dash with colon to make Docker image name
# centos-7 => centos:7, ubuntu-14.04 => ubuntu:14.04
IMAGE=$(echo ${FLOCKER_OS} | sed -e 's/^\([^-]*\)-/\1:/')

NAME=test-$$

${DOCKER} run --name ${NAME} -d -it -v ${TOP}/provision:/host ${IMAGE} /bin/bash

${DOCKER} exec ${NAME} /host/install-2.sh || true

connect=0
while [ "${connect}" -eq 0 ]; do
    ${DOCKER} exec -it ${NAME} /bin/bash --login || true
    read -p "reConnect, Terminate, or Quit (without terminating instance)?" ctq
    case $ctq in
        [Qq]*) exit ;;
        [Tt]*) connect=1 ;;
        *) ;;
    esac
done

${DOCKER} stop ${NAME}
${DOCKER} rm ${NAME}
