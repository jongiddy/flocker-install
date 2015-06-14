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

If you have previously installed a cluster and you wish to re-install the client (to change the branch, for example), remove the directory `flocker-client`, using:

```
rm -r flocker-client
```

To create a cluster, start with:
```
./cluster_init.sh [ <BRANCH> ]
```

Start the nodes for the cluster by running either the `vbox.sh` or `aws.sh`
repeatedly in different terminals.  By default, these commands start CentOS 7
instances.  To use Ubuntu 14.04, add `--os ubuntu-14.04`.

To start the control node, add the flag `--control`.
If the control node should not be an agent node, add `--no-agent`.

On the control node, run:
```
install-control.sh [ <BRANCH> ]
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
./run-test.sh
```

For AWS, use the external address for the `flocker-deploy` command, but the
internal IP addresses in the deployment file.
