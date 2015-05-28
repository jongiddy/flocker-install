#!/bin/bash

set -e -x

source /etc/os-release

OPSYS=${ID}-${VERSION_ID}

case "${OPSYS}" in
centos-7)
	sudo yum install -y kernel-devel kernel
	;;
fedora-20)
	# Extract main version number
	# 3.11.10-301.fc20.x86_64 -> 3.11.10
	KERNEL_VERSION=`expr match "$(uname -r)" '\([0-9.]*\)'`
	KERNEL_PARTS=($(echo ${KERNEL_VERSION} | tr "." "\n"))

	# Need kernel >= 3.16.4
	upgrade=
	MAJOR=${KERNEL_PARTS[0]}
	if [ "${MAJOR}" -lt 3 ]; then
		upgrade=true
	elif [ "${MAJOR}" -eq 3 ]; then
		MINOR=${KERNEL_PARTS[1]}
		if [ "${MINOR}" -lt 16 ]; then
			upgrade=true
		elif [ "${MINOR}" -eq 16 ]; then
			MICRO=${KERNEL_PARTS[2]}
			if [ "${MICRO}" -lt 4 ]; then
				upgrade=true
			fi
		fi
	fi

	if [ "${upgrade}" ]; then
		sudo yum upgrade -y kernel kernel-devel
		sudo grubby --set-default-index 0
	else
		# Don't need to upgrade kernel but do need kernel-devel libs
		# kernel-devel may not be available in standard repo for our kernel,
		# so use kojipkgs
		UNAME_R=$(uname -r)
		PV=${UNAME_R%.*}
		KV=${PV%%-*}
		SV=${PV##*-}
		ARCH=$(uname -m)
		sudo yum install -y https://kojipkgs.fedoraproject.org/packages/kernel/${KV}/${SV}/${ARCH}/kernel-devel-${UNAME_R}.rpm
	fi
	;;
ubuntu-14.04)
	;;
ubuntu-15.04)
	;;
*)
	echo "Unsupported operating system '${OPSYS}'" >&2
	exit 1
	;;
esac
