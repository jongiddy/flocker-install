#!/bin/bash

set -e

if [[ $EUID -eq 0 ]]; then
	# running as root - don't need sudo
	SUDO=
else
	SUDO=sudo
fi

set -x

FLOCKER_CONTROL_HOST=$1
FLOCKER_BACKEND=${2:-zfs}
FLOCKER_BRANCH=$3

source /etc/os-release

OPSYS=${ID}-${VERSION_ID}

case "${OPSYS}" in
centos-7 | fedora-20)
	case "${FLOCKER_BACKEND}" in
	zfs)
		${SUDO} yum install -y https://s3.amazonaws.com/archive.zfsonlinux.org/epel/zfs-release.el7.noarch.rpm
		case "${OPSYS}" in
		centos-7)
			${SUDO} yum install -y epel-release
			;;
		esac
		${SUDO} yum install -y zfs
		;;
	esac

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
	${SUDO} yum -y install ${branch_opt} clusterhq-flocker-node

	# Turn off SELinux if enabled
	if [ -r /etc/selinux/config ]; then
		${SUDO} setenforce 0
		${SUDO} sed --in-place='.preflocker' 's/^SELINUX=.*$/SELINUX=disabled/g' /etc/selinux/config
	fi
	;;
ubuntu-14.04)
	# Add ClusterHQ repository
	${SUDO} apt-get -y install apt-transport-https software-properties-common
	case "${FLOCKER_BACKEND}" in
	zfs)
		${SUDO} add-apt-repository -y ppa:zfs-native/stable
		# Wait till after apt-get update to install ZFS
		;;
	esac
	${SUDO} add-apt-repository -y ppa:james-page/docker
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

	case "${FLOCKER_BACKEND}" in
	zfs)
        ${SUDO} apt-get -y install libc6-dev
        ${SUDO} apt-get -y install zfsutils
		;;
	esac

	# Unauthenticated packages need --force-yes
	${SUDO} apt-get -y --force-yes install clusterhq-flocker-node
	;;
esac

# Install node certificates
${SUDO} mkdir -p /etc/flocker
${SUDO} chmod u=rwX,g=,o= /etc/flocker
${SUDO} mv cluster.crt /etc/flocker/cluster.crt
${SUDO} mv node.crt /etc/flocker/node.crt
${SUDO} mv node.key /etc/flocker/node.key

case "${FLOCKER_BACKEND}" in
zfs)
	# Ensure peer nodes can connect as root
	${SUDO} cp ~/.ssh/authorized_keys ~root/.ssh/authorized_keys
	# Create a ZFS pool
	${SUDO} mkdir -p /var/opt/flocker
	${SUDO} truncate --size 10G /var/opt/flocker/pool-vdev
	${SUDO} zpool create flocker /var/opt/flocker/pool-vdev
	;;
esac

cat > /tmp/agent.yml <<EOF
{
    "version": 1,
    "control-service": {
        "hostname": "${FLOCKER_CONTROL_HOST}",
        "port": 4524,
    },
    "dataset": {
        "backend": "${FLOCKER_BACKEND}",
    }
}
EOF
${SUDO} mv /tmp/agent.yml /etc/flocker/agent.yml

# Enable Flocker Node
case "${OPSYS}" in
centos-7 | fedora-20)
	${SUDO} systemctl enable flocker-dataset-agent
	${SUDO} systemctl start flocker-dataset-agent
	${SUDO} systemctl enable flocker-container-agent
	${SUDO} systemctl start flocker-container-agent
	;;
ubuntu-14.04)
    ${SUDO} service flocker-dataset-agent start
    ${SUDO} service flocker-container-agent start
	;;
esac

echo "Flocker Node installed."
