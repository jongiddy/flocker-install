#!/bin/bash

set -e

source ../../../secrets.sh

set -x

which aws || sudo pip install awscli

tmpdir=/tmp/flocker.$$

mkdir ${tmpdir}

cp install-1.sh ${tmpdir}/install-1.sh
cp install-2.sh ${tmpdir}/install-2.sh
cp Vagrantfile ${tmpdir}/Vagrantfile

cd ${tmpdir}

vagrant plugin install vagrant-aws
vagrant plugin install vagrant-reload

vagrant up --provider=aws

aws_id=$(cat .vagrant/machines/default/aws/id)
ipaddr=$(aws ec2 describe-instances --instance-ids ${aws_id} | sed -n -e 's/ *"PublicIpAddress": "\([0-9.]*\).*/\1/p')
echo "Flocker Node IP address: ${ipaddr}"

vagrant ssh

vagrant destroy --force

cd -

rm -fr ${tmpdir}
