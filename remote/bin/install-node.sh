#!/bin/bash

set -e -x

FLOCKER_CONTROL_HOST=$1
FLOCKER_BACKEND=${2:-zfs}
FLOCKER_BRANCH=$3

source /etc/os-release

OPSYS=${ID}-${VERSION_ID}

case "${OPSYS}" in
centos-7 | fedora-20)
	case "${FLOCKER_BACKEND}" in
	zfs)
		sudo yum install -y XXX
		case "${OPSYS}" in
		centos-7)
			sudo yum install -y epel-release
			;;
		esac
		sudo yum install -y zfs
		;;
	esac

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
	sudo yum -y install ${branch_opt} clusterhq-flocker-node
	;;
ubuntu-14.04)
	# Add ClusterHQ repository
	sudo apt-get -y install apt-transport-https software-properties-common
	case "${FLOCKER_BACKEND}" in
	zfs)
		sudo add-apt-repository -y ppa:zfs-native/stable
		# Wait till after apt-get update to install ZFS
		;;
	esac
	sudo add-apt-repository -y ppa:james-page/docker
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

	case "${FLOCKER_BACKEND}" in
	zfs)
        sudo apt-get -y install libc6-dev
        sudo apt-get -y install zfsutils
		;;
	esac

	# Unauthenticated packages need --force-yes
	sudo apt-get -y --force-yes install clusterhq-flocker-node
	;;
esac

# Install node certificates
sudo mkdir -p /etc/flocker
sudo chmod u=rwX,g=,o= /etc/flocker
sudo mv cluster.crt /etc/flocker/cluster.crt
sudo mv node.crt /etc/flocker/node.crt
sudo mv node.key /etc/flocker/node.key

case "${FLOCKER_BACKEND}" in
zfs)
	sudo mkdir -p /var/opt/flocker
	sudo truncate --size 10G /var/opt/flocker/pool-vdev
	sudo zpool create flocker /var/opt/flocker/pool-vdev
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
sudo mv /tmp/agent.yml /etc/flocker/agent.yml

# Enable Flocker Node
case "${OPSYS}" in
centos-7 | fedora-20)
	sudo systemctl enable flocker-dataset-agent
	sudo systemctl start flocker-dataset-agent
	sudo systemctl enable flocker-container-agent
	sudo systemctl start flocker-container-agent
	;;
ubuntu-14.04)
    sudo service flocker-dataset-agent start
    sudo service flocker-container-agent start
	;;
esac

echo "Flocker Node installed."
