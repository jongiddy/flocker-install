#!/bin/sh

set -e -x

tmpdir=/tmp/flocker.$$

mkdir ${tmpdir}

cp install-1.sh ${tmpdir}/install-1.sh
cp Vagrantfile ${tmpdir}/Vagrantfile

cd ${tmpdir}

vagrant up

vbox_id=`cat .vagrant/machines/default/virtualbox/id`
ipaddr=`VBoxManage guestproperty get "${vbox_id}" '/VirtualBox/GuestInfo/Net/1/V4/IP' | sed -e 's/Value: //'`
echo "Flocker Node IP address: ${ipaddr}"

vagrant ssh

vagrant destroy --force

cd -

rm -fr ${tmpdir}
