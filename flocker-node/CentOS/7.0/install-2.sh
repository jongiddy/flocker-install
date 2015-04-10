#!/bin/sh

set -e -x

# Add ClusterHQ and recent ZFS and Docker repositories
# Ignore status, as it may be yum having nothing to do if repo was installed previously.
sudo yum install -y epel-release
sudo yum install -y https://s3.amazonaws.com/archive.zfsonlinux.org/epel/zfs-release.el7.noarch.rpm || true
sudo yum install -y https://s3.amazonaws.com/clusterhq-archive/centos/clusterhq-release$(rpm -E %dist).noarch.rpm || true

# Add ClusterHQ packages
sudo yum install -y clusterhq-flocker-node

# Start Docker service
sudo systemctl enable docker.service
sudo systemctl start docker.service
