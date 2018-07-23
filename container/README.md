# suricata-docker
A CentOS based Suricata docker image with Hyperscan

The included suricata.yaml file utilizes cpu affinity on cores 12 - 17. This configuration depends on your NUMA node setup, otherwise it may degrade performance. 
