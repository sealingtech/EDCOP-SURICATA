#!/bin/bash
if [ ! -d "/logs/suricata" ]; then
  mkdir /logs/suricata
fi


sleep 10


wget -P / https://rules.emergingthreats.net/open/suricata/emerging.rules.tar.gz
tar xvzf /emerging.rules.tar.gz -C /

suricata -c /etc/suricata/suricata.yaml --af-packet 
