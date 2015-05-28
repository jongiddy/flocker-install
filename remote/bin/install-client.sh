#!/bin/bash

set -e -x

FLOCKER_BRANCH=$1

source /etc/os-release

OPSYS=${ID}-${VERSION_ID}

case "${OPSYS}" in
centos-7 | fedora-20)
	DEFAULT_REPO=https://s3.amazonaws.com/clusterhq-archive/${ID}/clusterhq-release$(rpm -E %dist).noarch.rpm

	# Add ClusterHQ repository
	# Ignore status, as it may be yum having nothing to do if repo was installed previously.
	sudo yum install -y "${DEFAULT_REPO}" || true

	if [ "${FLOCKER_BRANCH}" ]; then
		BUILDBOT_REPO=http://build.clusterhq.com/results/omnibus/${FLOCKER_BRANCH}/${OPSYS}
		cat > /tmp/repo <<EOF
[clusterhq-build]
name=clusterhq-build
baseurl=${BUILDBOT_REPO}
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
	;;
ubuntu-14.04)
	# Add ClusterHQ repository
	sudo apt-get -y install apt-transport-https software-properties-common
	sudo add-apt-repository -y 'deb https://clusterhq-archive.s3.amazonaws.com/ubuntu-testing/14.04/$(ARCH) /'

	if [ "${FLOCKER_BRANCH}" ]; then
		BUILDBOT_REPO=http://build.clusterhq.com/results/omnibus/${FLOCKER_BRANCH}/${OPSYS}
		sudo add-apt-repository -y "deb ${BUILDBOT_REPO} /"
		cat > /tmp/apt-pref <<EOF
Package:  *
Pin: origin build.clusterhq.com
Pin-Priority: 900
EOF
		sudo mv /tmp/apt-pref /etc/apt/preferences.d/buildbot-900
	fi

	sudo apt-get update

	# Unauthenticated packages need --force-yes
	sudo apt-get -y --force-yes install clusterhq-flocker-cli
	;;
esac

echo "Flocker CLI ${version} installed."
