#!/bin/sh

set -e -x

# Add ClusterHQ repository
sudo yum install -y https://s3.amazonaws.com/clusterhq-archive/centos/clusterhq-release$(rpm -E %dist).noarch.rpm

# Add ClusterHQ packages
sudo yum -y install clusterhq-python-flocker clusterhq-flocker-cli

echo "Flocker CLI ${version} installed."
