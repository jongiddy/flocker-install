#!/bin/sh

set -e -x

tmpdir=/tmp/flocker.$$

mkdir ${tmpdir}

cp install-1.sh ${tmpdir}/install-1.sh

cat > ${tmpdir}/Vagrantfile <<EOF
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "chef/centos-7.0"
  config.vm.provision :shell, :path => "install-1.sh", :privileged => false
end
EOF

cd ${tmpdir}

vagrant up

vagrant ssh

vagrant destroy --force

cd -

rm -fr ${tmpdir}
