#!/bin/bash

set -e

if [[ $EUID -eq 0 ]]; then
	# running as root - don't need sudo
	SUDO=
else
	SUDO=sudo
fi

set -x

FLOCKER_BRANCH=${1:-master}

source /etc/os-release

OPSYS=${ID}-${VERSION_ID}

case "${ID}" in
centos | fedora)
	${SUDO} yum install -y gcc python python-devel python-virtualenv libffi-devel openssl-devel
	;;
ubuntu)
	${SUDO} apt-get -y install gcc libssl-dev libffi-dev python2.7 python-virtualenv python2.7-dev
	;;
esac

[ ! -d flocker-client ] || rm -r flocker-client

virtualenv --python=/usr/bin/python2.7 flocker-client

source flocker-client/bin/activate

if [ -d git-flocker ]; then
	cd git-flocker
	git fetch origin
else
	git clone https://github.com/ClusterHQ/flocker.git git-flocker
	cd git-flocker
fi

git checkout ${FLOCKER_BRANCH}

git merge origin/${FLOCKER_BRANCH}

pip install -e .[release]

pip wheel .

pip install Flocker

echo "Flocker CLI installed."

echo "Run 'source flocker-client/bin/activate' to start using it."
