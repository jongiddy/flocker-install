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
ln -s cluster.crt ${tmpdir}/cluster.crt

ln -s ${TOP}/provision/* ${tmpdir}
ln -s ${TOP}/vagrant/Vagrantfile-${FLOCKER_OS} ${tmpdir}/Vagrantfile

cd ${tmpdir}

# If not installed, install the vagrant-reload plugin
vagrant plugin list | grep -q vagrant-reload || vagrant plugin install vagrant-reload

vagrant up

vbox_id=`cat .vagrant/machines/default/virtualbox/id`
ipaddr=`VBoxManage guestproperty get ${vbox_id} '/VirtualBox/GuestInfo/Net/1/V4/IP' | sed -e 's/Value: //'`
echo "Flocker Node IP address: ${ipaddr}"
if [ "${FLOCKER_CONTROL_NODE}" -ne 0 ]; then
    echo ${ipaddr} >> ${TOP}/control.txt
fi
if [ "${FLOCKER_AGENT_NODE}" -ne 0 ]; then
    echo ${ipaddr} >> ${TOP}/agents.txt
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
