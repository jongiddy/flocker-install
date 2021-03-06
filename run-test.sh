#!/bin/bash

set -e -x

source flocker-client/bin/activate

export FLOCKER_ACCEPTANCE_NUM_AGENT_NODES=$(cat agents.txt | wc -l)
export FLOCKER_ACCEPTANCE_CONTROL_NODE=$(cat control.txt)
export FLOCKER_ACCEPTANCE_VOLUME_BACKEND=zfs
export FLOCKER_ACCEPTANCE_API_CERTIFICATES_PATH=`pwd`
export FLOCKER_ACCEPTANCE_HOSTNAME_TO_PUBLIC_ADDRESS="{$(cat agent-map.txt | paste -s -d ',' -)}"

trial flocker.acceptance
