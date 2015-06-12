#!/bin/bash

set -e
set -a  # Variables from sourced files are exported to Vagrant commands

TOP=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

source read_server_args.sh "$0" "$@"

source secrets.sh

tmpdir=/tmp/flocker.$$

mkdir ${tmpdir}
chmod 700 ${tmpdir}

if [ "${FLOCKER_AGENT_NODE}" -ne 0 ]; then
    flocker-ca create-node-certificate --outputpath=${tmpdir}
    mv ${tmpdir}/*.crt ${tmpdir}/node.crt
    mv ${tmpdir}/*.key ${tmpdir}/node.key
fi
ln -s ${TOP}/cluster.crt ${tmpdir}/cluster.crt

ln -s ${TOP}/provision/* ${tmpdir}
ln -s ${TOP}/vagrant/Vagrantfile-${FLOCKER_OS} ${tmpdir}/Vagrantfile

cd ${tmpdir}

# If not installed, install the vagrant-reload plugin
vagrant plugin list | grep -q vagrant-reload || vagrant plugin install vagrant-reload

vagrant up

vbox_id=`cat .vagrant/machines/default/virtualbox/id`
hostname=`VBoxManage guestproperty get ${vbox_id} '/VirtualBox/GuestInfo/Net/1/V4/IP' | sed -e 's/Value: //'`
# Above works for Ubuntu, but not for CentOS
if [ -z "${hostname}" -o "${hostname}" = 'No value set!' ]; then
    hostname=$(vagrant ssh -- "/usr/sbin/ip addr show enp0s8 | grep 'inet ' | sed -e 's: *inet \([0-9.]*\).*$:\1:'")
fi

echo "Flocker Node IP address: ${hostname}"
if [ "${FLOCKER_AGENT_NODE}" -ne 0 ]; then
    echo ${hostname} >> ${TOP}/agents.txt
fi
if [ "${FLOCKER_CONTROL_NODE}" -ne 0 ]; then
    echo ${hostname} > ${TOP}/control.txt
    flocker-ca create-control-certificate ${hostname} --inputpath=${TOP}
    vagrant scp control-*.crt control-service.crt
    vagrant scp control-*.key control-service.key
fi

connect=0
while [ "${connect}" -eq 0 ]; do
    vagrant ssh || true
    read -p "reConnect, Terminate, or Quit (without terminating instance)?" ctq
    case $ctq in
        [Qq]*) exit ;;
        [Tt]*) connect=1 ;;
        *) ;;
    esac
done

vagrant destroy --force

cd -

rm -fr ${tmpdir}
