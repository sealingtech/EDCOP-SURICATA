#!/bin/bash
#
# This script resets the network interface defined by the $CAPTUREINT below and 
# adds the number of Virtual Functions (VFs) requested. At time of writing, only
# the Intel X710-based interfaces are able pass promiscuous traffic to a VF (trust mode)
#
# Requires: - Intel X710 based interface card
# 	    - RHEL/CentOS 7.3+ or OS with Kernel 4.4+
#
# Usage: reset-network.sh <num of VFs> 

if [[ $# -eq 0 ]] ; then
    echo 'ERROR: No Arg found'
    echo 'Usage: reset-network.sh <num of VFs>'
    echo 'Script contains some editable variables'
    exit 1
fi

###############################
#Edit these varibles as needed#
###############################
#
CAPTUREINT=ens2f0

ip -all netns delete
echo 0 > /sys/class/net/$CAPTUREINT/device/sriov_numvfs
sleep 1
echo $1 > /sys/class/net/$CAPTUREINT/device/sriov_numvfs

for i in $(eval echo {1..$1})
do
if [ "$i" -gt '10' ]
then
#Set the interfaces required
ip link set dev $CAPTUREINT vf $(($i - 1)) trust on
ip link set dev $CAPTUREINT vf $(($i - 1)) vlan 10$(($i - 1))
ip link set dev $CAPTUREINT vf $(($i - 1)) spoofchk off
ip link set dev $CAPTUREINT vf $(($i - 1)) mac 0:52:44:11:22:$(($i - 1))
else 
ip link set dev $CAPTUREINT vf $(($i - 1)) trust on
ip link set dev $CAPTUREINT vf $(($i - 1)) vlan 100$(($i - 1))
ip link set dev $CAPTUREINT vf $(($i - 1)) spoofchk off
ip link set dev $CAPTUREINT vf $(($i - 1)) mac 0:52:44:11:22:3$(($i - 1))
fi
done

#Reload VF Kernel Module
rmmod i40evf
modprobe i40evf

