#!/bin/bash

set -e

if [[ $EUID -eq 0 ]]; then
	# running as root - don't need sudo
	SUDO=
else
	SUDO=sudo
fi

set -x

FLOCKER_BRANCH=$1

source /etc/os-release

OPSYS=${ID}-${VERSION_ID}

case "${ID}" in
centos | fedora)
	${SUDO} yum install -y gcc python python-devel python-virtualenv libffi-devel openssl-devel
	;;
ubuntu)
	# Some minimal Ubuntu's (e.g. Docker ubuntu images) need the apt cache
	# updated before installing some of these packages
	${SUDO} apt-get update
	${SUDO} apt-get -y install gcc libssl-dev libffi-dev python2.7 python-virtualenv python2.7-dev
	;;
esac

virtualenv --python=/usr/bin/python2.7 flocker-client

source flocker-client/bin/activate

pip install --upgrade pip
pip install https://clusterhq-archive.s3.amazonaws.com/python/Flocker-1.0.3-py2-none-any.whl

echo "Flocker CLI installed."

echo "Run 'source flocker-client/bin/activate' to start using it."
