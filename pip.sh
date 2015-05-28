#!/bin/bash

set -e

source /etc/os-release

OPSYS=${ID}-${VERSION_ID}

case "${OPSYS}" in
centos-7)
	sudo yum install gcc python python-devel python-virtualenv
	;;
fedora-20)
	sudo yum install gcc python python-devel python-virtualenv
	;;
ubuntu-14.04)
	sudo apt-get install gcc python2.7 python-virtualenv python2.7-dev
	;;
esac

virtualenv --python=/usr/bin/python2.7 flocker-client
flocker-client/bin/pip install --upgrade pip
flocker-client/bin/pip install https://clusterhq-archive.s3.amazonaws.com/python/Flocker-0.4.1dev1-py2-none-any.whl
