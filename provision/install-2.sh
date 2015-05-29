#!/bin/bash

set -e

if [[ $EUID -eq 0 ]]; then
	# running as root - don't need sudo
	SUDO=
else
	SUDO=sudo
fi

set -x

source /etc/os-release

OPSYS=${ID}-${VERSION_ID}

case "${OPSYS}" in
centos-7 | fedora-20)
	${SUDO} yum install -y git
	;;
ubuntu-14.04)
	export DEBIAN_FRONTEND=noninteractive
	${SUDO} apt-get --assume-yes install git
	;;
ubuntu-15.04)
	export DEBIAN_FRONTEND=noninteractive
	${SUDO} apt-get --assume-yes install git
	;;
*)
	echo "Unsupported operating system '${OPSYS}'" >&2
	exit 1
	;;
esac

git clone https://github.com/jongiddy/flocker-install.git

if [ -r ${HOME}/.bash_profile ]; then
	initfile=${HOME}/.bash_profile
else
	initfile=${HOME}/.bashrc
fi
PWD=$(pwd)
echo 'PATH=${PATH}:${PWD%/}/flocker-install/remote/bin' >> ${initfile}
