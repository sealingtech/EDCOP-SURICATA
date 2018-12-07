#!/bin/bash
# Suricata entrypoint script

set -e

if [ ! -d "/logs/suricata" ]; then
  mkdir -p /logs/suricata
fi

cp -rpf /tmp/suricata/* /etc/suricata/

sed -i 's/${INTERFACE1}/'$INTERFACE1' /g' /etc/suricata/suricata.yaml
sed -i 's/${INTERFACE2}/'$INTERFACE2' /g' /etc/suricata/suricata.yaml


# Start Suricata normally
suricata -c /etc/suricata/suricata.yaml --af-packet
