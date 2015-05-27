#!/bin/bash

set -e -x

# Remove any trailing slash
FLOCKER_REPO=${1%/}

# Add ClusterHQ repository
sudo apt-get -y install apt-transport-https software-properties-common
sudo add-apt-repository -y 'deb https://clusterhq-archive.s3.amazonaws.com/ubuntu-testing/14.04/$(ARCH) /'

if [ "${FLOCKER_REPO}" ]; then
	sudo add-apt-repository -y "deb ${FLOCKER_REPO} /"
	cat > /tmp/apt-pref <<EOF
Package:  *
Pin: origin {}
Pin-Priority: 900
EOF
	sudo mv /tmp/apt-pref /etc/apt/preferences.d/buildbot-900
fi

sudo apt-get update

# Unauthenticated packages need --force-yes
sudo apt-get -y --force-yes install clusterhq-flocker-cli

echo "Flocker CLI ${version} installed."
