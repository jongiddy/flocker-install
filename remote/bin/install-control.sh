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
	sudo yum -y install ${branch_opt} clusterhq-flocker-node
	;;
ubuntu-14.04)
	# Add ClusterHQ repository
	sudo apt-get -y install apt-transport-https software-properties-common
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

	# Unauthenticated packages need --force-yes
	sudo apt-get -y --force-yes install clusterhq-flocker-node
	;;
esac

# Install control certificates
sudo mkdir -p /etc/flocker
sudo chmod u=rwX,g=,o= /etc/flocker
sudo mv cluster.crt /etc/flocker/cluster.crt
sudo mv control.crt /etc/flocker/control-service.crt
sudo mv control.key /etc/flocker/control-service.key

# Enable Flocker Control
case "${OPSYS}" in
centos-7 | fedora-20)
	sudo systemctl enable flocker-control
	sudo systemctl start flocker-control
	sudo firewall-cmd --permanent --add-service flocker-control-api
	sudo firewall-cmd --add-service flocker-control-api
	sudo firewall-cmd --permanent --add-service flocker-control-agent
	sudo firewall-cmd --add-service flocker-control-agent
	;;
ubuntu-14.04)
	cat > /tmp/upstart.override <<EOF
start on runlevel [2345]
stop on runlevel [016]
EOF
	sudo mv /tmp/upstart.override /etc/init/flocker-control.override
	cp /etc/services /tmp/services
	echo 'flocker-control-api\t4523/tcp\t\t\t# Flocker Control API port' >> /tmp/services
    echo 'flocker-control-agent\t4524/tcp\t\t\t# Flocker Control Agent port' >> /tmp/services
    sudo cp /tmp/services /etc/services
    sudo service flocker-control start
    sudo ufw allow flocker-control-api
    sudo ufw allow flocker-control-agent
	;;
esac

echo "Flocker Control installed."
