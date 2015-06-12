#!/bin/bash

[ ! -r cluster.crt ] || rm cluster.crt
[ ! -r cluster.key ] || rm cluster.key

flocker-ca initialize mycluster

rm -f control.txt agents.txt
