# flocker-install
Installation scripts for Flocker


## AWS

To use AWS, copy the file `secrets.sh.example` to `secrets.sh` and fill in the
values.

## Cluster

It is simplest to run a client locally, using `local/pip.sh`.
Once this is installed, run:

```
cd flocker-client

./bin/flocker-ca initialize mycluster

./bin/flocker-ca create-control-certificate <CONTROL-SERVICE-IP>
scp cluster.crt centos@<CONTROL-SERVICE-IP>:cluster.crt
scp control-<CONTROL-SERVICE-IP>.crt centos@<CONTROL-SERVICE-IP>:control.crt
scp control-<CONTROL-SERVICE-IP>.key centos@<CONTROL-SERVICE-IP>:control.key

```

On the control node, run:
```
install-control.sh [ <BRANCH> ]
```

If a branch is provided, the latest build of that branch will be installed.
If no branch is provided, the latest release will be installed.

For each agent node, locally run:

```
./bin/flocker-ca create-node-certificate <NODE-SERVICE-IP>
scp cluster.crt centos@<NODE-SERVICE-IP>:cluster.crt
scp node-<NODE-SERVICE-IP>.crt centos@<NODE-SERVICE-IP>:node.crt
scp node-<NODE-SERVICE-IP>.key centos@<NODE-SERVICE-IP>:node.key

```

On each node, run:
```
install-node.sh <CONTROL-SERVICE-IP> [ <BACKEND> ] [ <BRANCH> ]
```

