#!/bin/bash

set -e

[ ! -r cluster.crt ] || rm cluster.crt
[ ! -r cluster.key ] || rm cluster.key
[ ! -r user.crt ] || rm user.crt
[ ! -r user.key ] || rm user.key

# Create a CA certificate
flocker-ca initialize mycluster

# Create a user certificate
flocker-ca create-api-certificate user

# Clear the control and agent hostname files
rm -f control.txt agents.txt
