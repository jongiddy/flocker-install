#!/bin/sh

set -e -x

# Add ClusterHQ repository
# Ignore status, as it may be yum having nothing to do if repo was installed previously.
sudo yum install -y https://s3.amazonaws.com/clusterhq-archive/centos/clusterhq-release$(rpm -E %dist).noarch.rpm || true

# Add ClusterHQ packages
sudo yum -y install clusterhq-python-flocker clusterhq-flocker-cli

echo "Flocker CLI ${version} installed."
