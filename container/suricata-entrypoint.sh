#!/bin/bash
# Suricata entrypoint script

set -e

if [ ! -d "/logs/suricata" ]; then
  mkdir -p /logs/suricata
fi

sed -i 's/${INTERFACE1}/'$INTERFACE1' /g' /tmp/suricata/suricata.yaml
sed -i 's/${INTERFACE2}/'$INTERFACE2' /g' /tmp/suricata/suricata.yaml

cp -rpf /tmp/suricata/* /etc/suricata/

# Start Suricata normally
suricata -c /etc/suricata/suricata.yaml --af-packet
