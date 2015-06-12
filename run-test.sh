#!/bin/bash

source flocker-client/bin/activate

export FLOCKER_ACCEPTANCE_NODES=$(cat control.txt agents.txt | sort | uniq | paste -s -d: -)
export FLOCKER_ACCEPTANCE_NUM_AGENT_NODES=$(cat control.txt agents.txt | sort | uniq | wc -l)
export FLOCKER_ACCEPTANCE_CONTROL_NODE=$(cat control.txt)
export FLOCKER_ACCEPTANCE_AGENT_NODES=$(cat agents.txt | paste -s -d: -)
export FLOCKER_ACCEPTANCE_VOLUME_BACKEND=zfs
export FLOCKER_ACCEPTANCE_API_CERTIFICATES_PATH=`pwd`

trial flocker.acceptance

