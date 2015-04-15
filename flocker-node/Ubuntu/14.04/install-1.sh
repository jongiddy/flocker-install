#!/bin/sh

set -e -x

# Add ClusterHQ and recent ZFS and Docker repositories

# Ensure add-apt-repository command is available
sudo apt-get -y install software-properties-common

# ZFS not available in base Ubuntu - add ZFS repo
sudo add-apt-repository -y ppa:zfs-native/stable

# Add Docker repo for recent Docker versions
sudo add-apt-repository -y ppa:james-page/docker

# Add ClusterHQ repo for installation of Flocker packages.
sudo add-apt-repository -y 'deb http://build.clusterhq.com/results/omnibus/master/ubuntu-14.04 /'

# Update to read package info from new repos
sudo apt-get update

# Package spl-dkms sometimes does not have libc6-dev as a
# dependency, add it before ZFS installation requires it.
sudo apt-get -y install libc6-dev

# Install Flocker node and all dependencies
# Unauthenticated packages need --force-yes
sudo apt-get -y --force-yes install clusterhq-flocker-node

# Create ZFS flocker pool
sudo mkdir -p /var/opt/flocker
sudo truncate --size 10G /var/opt/flocker/pool-vdev
sudo zpool create flocker /var/opt/flocker/pool-vdev

# Allow Flocker client access to root account
sudo mkdir -p ~root/.ssh
sudo chmod 700 ~root/.ssh
sudo cp ~/.ssh/authorized_keys ~root/.ssh/authorized_keys
