#!/bin/sh

set -e -x

# Add ClusterHQ and recent ZFS and Docker repositories
sudo apt-get -y install software-properties-common
sudo add-apt-repository -y ppa:zfs-native/stable
sudo add-apt-repository -y ppa:james-page/docker
sudo add-apt-repository -y 'deb http://build.clusterhq.com/results/omnibus/master/ubuntu-14.04 /'
sudo apt-get update

sudo apt-get -y install spl-dkms
sudo apt-get -y install zfs-dkms zfsutils docker.io

# Add ClusterHQ packages
# Unauthenticated packages need --force-yes
sudo apt-get -y --force-yes install clusterhq-python-flocker clusterhq-flocker-node
