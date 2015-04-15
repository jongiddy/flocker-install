#!/bin/bash

set -e

source ../../../secrets.sh

set -x

tmpdir=/tmp/flocker.$$

mkdir ${tmpdir}

cp install-1.sh ${tmpdir}/install-1.sh
cp Vagrantfile ${tmpdir}/Vagrantfile

cd ${tmpdir}

vagrant plugin install vagrant-aws

vagrant up --provider=aws

vagrant ssh

vagrant destroy --force

cd -

rm -fr ${tmpdir}
