#!/bin/sh

set -e -x

tmpdir=/tmp/flocker.$$

mkdir ${tmpdir}

cp ../../../common/fixtty.sh ${tmpdir}/fixtty.sh
cp install-1.sh ${tmpdir}/install-1.sh
cp Vagrantfile ${tmpdir}/Vagrantfile

cd ${tmpdir}

vagrant up

vagrant ssh

vagrant destroy --force

cd -

rm -fr ${tmpdir}
