#!/bin/bash

set -e -x

source /etc/os-release

OPSYS=${ID}-${VERSION_ID}

case "${OPSYS}" in
centos-7 | fedora-20)
	sudo yum install -y git
	;;
ubuntu-14.04)
	sudo apt-get --assume-yes install git
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
echo 'PATH=${PATH}:${HOME}/flocker-install/remote/bin' >> initfile
