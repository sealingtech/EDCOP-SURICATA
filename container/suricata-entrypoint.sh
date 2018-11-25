#!/bin/bash
# Suricata entrypoint script

set -e

if [ ! -d "/logs/suricata" ]; then
  mkdir -p /logs/suricata
fi

sleep 10

wget -P / https://repos.dds.io/rules/emerging.rules.tar.gz
tar xvzf /emerging.rules.tar.gz -C /


# Start Suricata normally
suricata -c /etc/suricata/suricata.yaml --af-packet
