#!/bin/sh

set -e -x

# Install kernel-devel package
UNAME_R=$(uname -r)
PV=${UNAME_R%.*}
KV=${PV%%-*}
SV=${PV##*-}
ARCH=$(uname -m)
sudo yum install -y https://kojipkgs.fedoraproject.org/packages/kernel/${KV}/${SV}/${ARCH}/kernel-devel-${UNAME_R}.rpm

# Add ClusterHQ and recent ZFS and Docker repositories
sudo yum install -y https://s3.amazonaws.com/archive.zfsonlinux.org/fedora/zfs-release$(rpm -E %dist).noarch.rpm
sudo yum install -y https://s3.amazonaws.com/clusterhq-archive/fedora/clusterhq-release$(rpm -E %dist).noarch.rpm

# Add ClusterHQ packages
sudo yum install -y clusterhq-flocker-node

# Start Docker service
sudo systemctl enable docker.service
sudo systemctl start docker.service
