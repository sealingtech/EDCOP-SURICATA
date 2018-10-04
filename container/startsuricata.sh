#!/bin/bash
###############################
#Only edit this variable below#
###############################

#CONTAINERINT is the interface within the Container
CONTAINERINT="changeme"

#echo "Setting Runmode..."
#sed -i 's/#runmode: autofp/runmode: workers/' /etc/suricata/suricata.yaml
echo "Setting AF-Packet Interface to $CONTAINERINT..."
sed -i '/^'af-packet'/,/^[   ]*$/{/'"interface:"'/s/\('interface:'\)\(.*$\)/\1'" $CONTAINERINT"'/}' /etc/suricata/suricata.yaml
echo "Creating Random ClusterID for AF-Packet..."
sed -i '/^'af-packet'/,/^[   ]*$/{/'"cluster-id:"'/s/\('cluster-id:'\)\(.*$\)/\1'" $RANDOM"'/}' /etc/suricata/suricata.yaml
#echo "Enabling mmap..."
#sed -i '/^'af-packet'/,/^[   ]*$/{ s/#use-mmap/use-mmap/}' /etc/suricata/suricata.yaml
#echo "Enabling AF-Packet V3..."
#sed -i '/^'af-packet'/,/^[   ]*$/{ s/#tpacket-v3/tpacket-v3/}' /etc/suricata/suricata.yaml
echo "Starting Suricata with command \"suricata --af-packet -vv\"..."
suricata --af-packet -vv -c /etc/suricata/suricata.yaml
