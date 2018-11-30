# EDCOP Suricata Guide

Table of Contents
-----------------
 
* [Configuration Guide](#configuration-guide)
	* [Image Repository](#image-repository)
	* [Networks](#networks)
	* [Node Selector](#node-selector)
	* [Deployment Options](#deployment-options)
	* [Suricata Configuration](#suricata-configuration)
		* [Inline/Passive Mode](#inline/passive-mode)
		* [Threads](#threads)
		* [CPU Affinity](#cpu-affinity)
		* [Resource Limits](#resource-limits)
	* [Logstash Configuration](#logstash-configuration)
	* [Redis Configuration](#redis-configuration)
		
# Configuration Guide

Within this configuration guide, you will find instructions for modifying Suricata's helm chart. All changes should be made in the *values.yaml* file.
Please share any bugs or features requests via GitHub issues.
 
## Image Repository

By default, images are pulled from official EDCOP's official repositorie, and the respective tool's official repository. If you're changing this value, make sure you use the full repository name.
 
```
images:
  suricata: gcr.io/edcop-public/suricata:2
  logstash: docker.elastic.co/logstash/logstash:6.5.1
  redis: redis:4.0.9
  runner: gcr.io/edcop-public/runner:8
```
 
## Networks

Suricata uses 2 or 3 interfaces depending on whether it is in passive or inline mode. If you choose passive mode, net2 will be ignored and net1 will be the name of the passive interface.
By default, these interfaces are named *calico*, *passive*, *inline-1*, and *inline-2*.
When useHostNetworking is set to true these interfaces are named *calico*, and the names of the interfaces you used in [EDCOP-CONFIGURESENSORS](https://github.com/sealingtech/EDCOP-CONFIGURESENSORS).

useHostNetworking is used in situations where container networking is insufficient (such as the lack of SR-IOV).  This allows the container to see all physical interfaces of the nodes.  This has some security concerns due to the fact that Suricata now have access to all physical networking.  When useHostNetworking is set, the interface names will be pulled from the secrets created by the CONFIGURESENSORS repository. If using passive mode only the *passive interface* will be used. If using inline, then both *inline-interface1* and *inline-interface2* will be used. When useHostNetworking is specified, the container will still be joined to the Calico network, but will ignore passive, inline-1, and inline-2 SR-IOV networks. 

```
networks:
  overlay: calico
  net1: passive
  net2: 
  
suricataConfig:
  useHostNetworking: false
  inline: false
```

```
networks:
  overlay: calico
  net1: inline-1
  net2: inline-2
  
suricataConfig:
  useHostNetworking: false
  inline: true
```

```
networks:
  overlay: calico
  
suricataConfig:
  useHostNetworking: true
```
 
To find the names of your networks, use the following command:
 
```
# kubectl get networks
NAME		AGE
calico		1d
inline-1	1d
inline-2	1d
```
 
## Node Selector

This value tells Kubernetes which hosts the daemonset should be deployed to by using labels given to the hosts. Hosts without the defined label will not receive pods. Suricata will only deploy to nodes that have been labeled 'sensor=true'
 
```
nodeSelector:
    label: sensor
```
 
To find out what labels your hosts have, please use the following:
```
# kubectl get nodes --show-labels
NAME		STATUS		ROLES		AGE		VERSION		LABELS
master 		Ready		master		1d		v1.9.1		...,infrastructure=true
minion-1	Ready		<none>		1d		v1.9.1		...,sensor=true
minion-2	Ready		<none>		1d		v1.9.1		...,sensor=true
```

## Deployment Options

For a detailed explanation on how the deployment modes work, please click [here](https://github.com/SealingTech/EDCOP-TOOLS/blob/master/docs/Deployment_Options.md).
External options will only be used if you're in external mode and Redis is located on another host. 

```
deploymentOptions:
  deployment: standalone
  externalOptions:
    externalHost: 192.168.0.1
	nodePort: 30029
```

## Suricata Configuration

alertsOnly when set to true in the values.yaml will disable logs for http,dns,tls,smtp. This is common when using another tool that may already be recording this such as Bro. It will still provide alerts.

Suricata can be deployed in either inline or passive mode depending on how your cluster is setup. Inline mode will route traffic through the box for active threat detection and mitigation, while passive mode simply alerts you to potential threats. For an inline mode setup, the following is required:
 
 * An external traffic loadbalancer passing traffic through 2 interfaces on the host. 
 * An SR-IOV capable NIC with a sufficient number of VFs created for each interface being used.  
 * A total of 3 Kubernetes networks:
	* An overlay network to pass container traffic (Calico by default).
	* One SR-IOV network to accept network traffic and output to the second network.
	* A second SR-IOV network to accept network traffic from the first interface and output it back to the loadbalancer.
 
### Inline/Passive Mode

As mentioned before, if *inline* is set to true, Suricata will be deployed in inline mode and will require 2 networks for passing traffic. Setting to *false* will enable passive mode.
The home and external net settings tell suricata what you consider your internal and external network spaces. You can customize these as needed, but the external net is usually !$HOME_NET for simplicity. 

```
suricataConfig:
  inline: true
  homeNet: '[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12]'
  externalNet: '!$HOME_NET'
```

### Threads

If Suricata is set to inline mode, you will need to specify threads for both net0 and net1. The more threads you have, the more CPU space is required for packet processing. 
 
```
suricataConfig:
  ...
  net0Threads: 1
  net1Threads: 1
```

### CPU Affinity

Similarly, CPU affinity will utilize specific cores for packet processing. This setting will significantly increase performance, but should be used with cpu isolation to maximize individual core potential.
For the cpusets, enter either a single core or range of cpus as shown below:
 
```
suricataConfig:
  ...
  setCpuAffinity: yes
  recieveCpuSet: 0-2
  workerCpuSet: 3-7
  workerThreads: 1
  verdictCpuSet: 8-10
```
*For worker CPU sets, please refer to your NUMA node configuration to prevent cache thrashing.*

### Resource Limits

You can set limits on Suricata to ensure it doesn't use more CPU/memory space than necessary. Finding the right balance can be tricky, so some testing may be required.

```
suricataConfig:
  limits:
    cpu: 2
    memory: 4G
```

## Logstash Configuration

Logstash is only included in the Daemonset if you're using standalone mode and is used to streamline the rules required for the data it ingests. Having one Logstash instance per node would clutter rules and cause congestion with log filtering, which would harm our events/second speed. This instance will only deal with Suricata's logs and doesn't need complicated filters to figure out which tool the logs came from.
Please make sure to read the [Logstash Performance Tuning Guide](https://www.elastic.co/guide/en/logstash/current/performance-troubleshooting.html) for a better understanding of managing Logstash's resources. 

```
logstashConfig:
  threads: 2 
  batchCount: 250
  initialJvmHeap: 4g
  maxJvmHeap: 4g
  pipelineOutputWorkers: 2 
  pipelineBatchSize: 150  
  limits:
    cpu: 2
    memory: 8G
```

## Redis Configuration

Redis is also included in the Daemonset (except for external mode) for the same reasons Logstash is. Currently, you can only limit the resources of Redis in this section, but in the future we would like to add configmaps for tuning purposes. 

```
redisConfig:
  limits:
    cpu: 2
    memory: 8G
```
# EDCOP-SURICATA
