#!/bin/bash
# Suricata entrypoint script

set -e

if [ ! -d "/logs/suricata" ]; then
  mkdir -p /logs/suricata
fi


# Start Suricata normally
suricata -c /etc/suricata/suricata.yaml --af-packet
