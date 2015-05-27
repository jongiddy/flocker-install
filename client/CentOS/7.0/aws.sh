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

FLOCKER_REPO="$1" vagrant up --provider=aws

vagrant ssh || true

vagrant destroy --force

cd -

rm -fr ${tmpdir}
