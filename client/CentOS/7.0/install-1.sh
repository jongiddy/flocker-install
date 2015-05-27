#!/bin/bash

set -e -x

DEFAULT_REPO=https://s3.amazonaws.com/clusterhq-archive/centos/clusterhq-release$(rpm -E %dist).noarch.rpm
# Remove any trailing slash
FLOCKER_REPO=${1%/}

# Add ClusterHQ repository
# Ignore status, as it may be yum having nothing to do if repo was installed previously.
sudo yum install -y "${DEFAULT_REPO}" || true

if [ "${FLOCKER_REPO}" ]; then
	cat > /tmp/repo <<EOF
[clusterhq-build]
name=clusterhq-build
baseurl=${FLOCKER_REPO}
gpgcheck=0
enabled=0
EOF
	sudo mv /tmp/repo /etc/yum.repos.d/clusterhq-build.repo
	branch_opt=--enablerepo=clusterhq-build
else
	branch_opt=
fi

# Add ClusterHQ packages
sudo yum -y install ${branch_opt} clusterhq-flocker-cli

echo "Flocker CLI ${version} installed."
