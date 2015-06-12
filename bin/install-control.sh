#!/bin/bash

set -e

if [[ $EUID -eq 0 ]]; then
	# running as root - don't need sudo
	SUDO=
else
	SUDO=sudo
fi

set -x

CONTROL_HOST=$1
FLOCKER_BRANCH=$2

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
	# Install cli package to get flocker-ca command
	${SUDO} yum -y install ${branch_opt} clusterhq-flocker-node
	;;
ubuntu-14.04)
	# Add ClusterHQ repository
	${SUDO} apt-get -y install apt-transport-https software-properties-common
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

	# Unauthenticated packages need --force-yes
	# Install cli package to get flocker-ca command
	${SUDO} apt-get -y --force-yes install clusterhq-flocker-node
	;;
esac

# Install control certificates
${SUDO} mkdir -p /etc/flocker
${SUDO} chmod u=rwX,g=,o= /etc/flocker
${SUDO} cp cluster.crt /etc/flocker/cluster.crt
${SUDO} mv control-service.crt /etc/flocker/control-service.crt
${SUDO} mv control-service.key /etc/flocker/control-service.key
${SUDO} chmod 600 /etc/flocker/control-service.key

# Enable Flocker Control
case "${OPSYS}" in
centos-7 | fedora-20)
	# Setup firewall
	if [ "$(which firewall-cmd)" ]; then
		${SUDO} firewall-cmd --add-service ssh --permanent
		${SUDO} firewall-cmd --add-service flocker-control-api --permanent
		${SUDO} firewall-cmd --add-service flocker-control-agent --permanent
		${SUDO} firewall-cmd --reload
	fi
	# Start control service
	${SUDO} systemctl enable flocker-control
	${SUDO} systemctl start flocker-control
	;;
ubuntu-14.04)
	# Setup firewall
	cp /etc/services /tmp/services
	echo 'flocker-control-api\t4523/tcp\t\t\t# Flocker Control API port' >> /tmp/services
    echo 'flocker-control-agent\t4524/tcp\t\t\t# Flocker Control Agent port' >> /tmp/services
    ${SUDO} cp /tmp/services /etc/services
    if [ "$(which ufw)" ]; then
	    ${SUDO} ufw allow ssh
	    ${SUDO} ufw allow flocker-control-api
	    ${SUDO} ufw allow flocker-control-agent
	fi
    # Start control service
	cat > /tmp/upstart.override <<EOF
start on runlevel [2345]
stop on runlevel [016]
EOF
	${SUDO} mv /tmp/upstart.override /etc/init/flocker-control.override
    ${SUDO} service flocker-control start
	;;
esac

echo "Flocker Control installed."
