#!/bin/bash

set -e

if [[ $EUID -eq 0 ]]; then
	# running as root - don't need sudo
	SUDO=
else
	SUDO=sudo
fi

set -x

FLOCKER_BRANCH=$1

source /etc/os-release

OPSYS=${ID}-${VERSION_ID}

case "${OPSYS}" in
centos-7 | fedora-20)
	DEFAULT_REPO=https://s3.amazonaws.com/clusterhq-archive/${ID}/clusterhq-release$(rpm -E %dist).noarch.rpm

	# Add ClusterHQ repository
	# Ignore status, as it may be yum having nothing to do if repo was installed previously.
	${SUDO} yum install -y "${DEFAULT_REPO}" || true

	if [ "${FLOCKER_BRANCH}" ]; then
		BUILDBOT_REPO=http://build.clusterhq.com/results/omnibus/${FLOCKER_BRANCH}/${OPSYS}
		cat > /tmp/repo <<EOF
[clusterhq-build]
name=clusterhq-build
baseurl=${BUILDBOT_REPO}
gpgcheck=0
enabled=0
EOF
		${SUDO} mv /tmp/repo /etc/yum.repos.d/clusterhq-build.repo
		branch_opt=--enablerepo=clusterhq-build
	else
		branch_opt=
	fi

	# Add ClusterHQ packages
	${SUDO} yum -y install ${branch_opt} clusterhq-flocker-cli
	;;
ubuntu-14.04)
	# Add ClusterHQ repository
	${SUDO} apt-get -y install apt-transport-https software-properties-common
	${SUDO} add-apt-repository -y 'deb https://clusterhq-archive.s3.amazonaws.com/ubuntu-testing/14.04/$(ARCH) /'

	if [ "${FLOCKER_BRANCH}" ]; then
		BUILDBOT_REPO=http://build.clusterhq.com/results/omnibus/${FLOCKER_BRANCH}/${OPSYS}
		${SUDO} add-apt-repository -y "deb ${BUILDBOT_REPO} /"
		cat > /tmp/apt-pref <<EOF
Package:  *
Pin: origin build.clusterhq.com
Pin-Priority: 900
EOF
		${SUDO} mv /tmp/apt-pref /etc/apt/preferences.d/buildbot-900
	fi

	${SUDO} apt-get update

	# Unauthenticated packages need --force-yes
	${SUDO} apt-get -y --force-yes install clusterhq-flocker-cli
	;;
ubuntu-15.04)
	# Add ClusterHQ repository
	${SUDO} apt-get -y install apt-transport-https software-properties-common
	${SUDO} add-apt-repository -y 'deb https://clusterhq-archive.s3.amazonaws.com/ubuntu-testing/14.04/$(ARCH) /'

	if [ "${FLOCKER_BRANCH}" ]; then
		# no 15.04 repo yet - use 14.04
		BUILDBOT_REPO=http://build.clusterhq.com/results/omnibus/${FLOCKER_BRANCH}/ubuntu-14.04
		${SUDO} add-apt-repository -y "deb ${BUILDBOT_REPO} /"
		cat > /tmp/apt-pref <<EOF
Package:  *
Pin: origin build.clusterhq.com
Pin-Priority: 900
EOF
		${SUDO} mv /tmp/apt-pref /etc/apt/preferences.d/buildbot-900
	fi

	${SUDO} apt-get update

	# Unauthenticated packages need --force-yes
	${SUDO} apt-get -y --force-yes install clusterhq-flocker-cli
	;;
*)
	echo "Unsupported operating system '${OPSYS}'" >&2
	exit 1
	;;
esac

echo "Flocker CLI installed."
