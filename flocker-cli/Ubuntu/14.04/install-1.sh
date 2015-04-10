#!/bin/sh

set -e -x

# Add ClusterHQ repository
sudo apt-get -y install software-properties-common
sudo add-apt-repository -y 'deb http://build.clusterhq.com/results/omnibus/master/ubuntu-14.04 /'
sudo apt-get update

# Unauthenticated packages need --force-yes
sudo apt-get -y --force-yes install clusterhq-python-flocker clusterhq-flocker-cli

echo "Flocker CLI ${version} installed."
