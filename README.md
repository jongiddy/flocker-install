# flocker-install
Installation scripts for Flocker

The user account on the remote systems must be logged in as a user who has root
access. If these scripts are run non-interactively, sudo access must be
passwordless.

Note, these scripts cheat on the certificate creation by copying the CA private
key to each node.  Do not do this in production!

## AWS

To use AWS, copy the file `secrets.sh.example` to `secrets.sh` and fill in the
values.

## Cluster

It is simplest to run a client locally, using:

```
./bin/install-client-src.sh [ <BRANCH> ]
source ./flocker-client/bin/activate
flocker-ca initialize mycluster
```

Start the nodes for the cluster by running either the `vbox.sh` or `aws.sh`
repeatedly in different terminals.  By default, these commands start CentOS 7
instances.  To use Ubuntu 14.04, add `--os ubuntu14.04`.

On the control node, run:
```
install-control.sh <CONTROL-SERVICE-HOST> [ <BRANCH> ]
```

where `<CONTROL-SERVICE-HOST>` is the external DNS or IP address of the control
node, and `<BRANCH>` is an optional Flocker branch.
If a branch is provided, the latest build of that branch will be installed.
If no branch is provided, the latest release will be installed.

On each node, run:
```
install-node.sh <CONTROL-SERVICE-HOST> [ <BACKEND> ] [ <BRANCH> ]
```

On the client, edit `run_tests.sh` to include the IP's of nodes and run:
```
flocker-ca create-api-certificate user
./run-test.sh
```