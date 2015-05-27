#!/bin/sh

set -e -x

tmpdir=/tmp/flocker.$$

mkdir ${tmpdir}

cp install-1.sh ${tmpdir}/install-1.sh
cp Vagrantfile ${tmpdir}/Vagrantfile

cd ${tmpdir}

FLOCKER_REPO="$1" vagrant up

vagrant ssh || true

vagrant destroy --force

cd -

rm -fr ${tmpdir}
