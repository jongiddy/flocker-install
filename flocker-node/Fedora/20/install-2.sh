#!/bin/sh

set -e -x

# Add ClusterHQ and recent ZFS and Docker repositories
# Ignore status, as it may be yum having nothing to do if repo was installed previously.
sudo yum install -y https://s3.amazonaws.com/archive.zfsonlinux.org/fedora/zfs-release$(rpm -E %dist).noarch.rpm || true
sudo yum install -y https://s3.amazonaws.com/clusterhq-archive/fedora/clusterhq-release$(rpm -E %dist).noarch.rpm || true

# Add ClusterHQ packages
sudo yum install -y clusterhq-flocker-node

# Start Docker service
sudo systemctl enable docker.service
sudo systemctl start docker.service

# Create ZFS flocker pool
sudo mkdir -p /var/opt/flocker
sudo truncate --size 10G /var/opt/flocker/pool-vdev
sudo zpool create flocker /var/opt/flocker/pool-vdev

# Allow Flocker client access to root account
sudo cp ~/.ssh/authorized_keys ~root/.ssh/authorized_keys
