# flocker-install
Installation scripts for Flocker


## AWS

To use AWS, copy the file `secrets.sh.example` to `secrets.sh` and fill in the
values.

## Cluster

It is simplest to run a client locally, using `./pip.sh`.
Once this is installed, run:

```
source ./flocker-client/bin/activate

flocker-ca initialize mycluster

CONTROL_HOST=<CONTROL-SERVICE-HOST>
CONTROL_USER=<CONTROL-SERVICE-USER>

flocker-ca create-control-certificate ${CONTROL_HOST}
scp cluster.crt ${CONTROL_USER}@${CONTROL_HOST}:cluster.crt
scp control-${CONTROL_HOST}.crt ${CONTROL_USER}@${CONTROL_HOST}:control.crt
scp control-${CONTROL_HOST}.key ${CONTROL_USER}@${CONTROL_HOST}:control.key

```

On the control node, run:
```
install-control.sh [ <BRANCH> ]
```

If a branch is provided, the latest build of that branch will be installed.
If no branch is provided, the latest release will be installed.

For each agent node, locally run:

```
NODE_HOST=<NODE-SERVICE-HOST>
NODE_USER=<NODE-SERVICE-USER>

flocker-ca create-node-certificate
scp cluster.crt ${NODE_USER}@${NODE_HOST}:cluster.crt
```
Set `NODE_UUID` to the UUID part of filename output by the `flocker-ca` command
```
scp ${NODE_UUID}.crt ${NODE_USER}@${NODE_HOST}:node.crt
scp ${NODE_UUID}.key ${NODE_USER}@${NODE_HOST}:node.key

```

On each node, run:
```
install-node.sh <CONTROL-SERVICE-HOST> [ <BACKEND> ] [ <BRANCH> ]
```

On the client, edit `run_tests.sh` to include the IP's of nodes and run:
```
flocker-ca create-api-certificate user
./run_tests.sh
```