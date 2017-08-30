# Deploy SJ via Vagrant

## Required
At least 8GB free ram.
Be careful, this is minimal memory require to launch platform.

VT-x must be enabled in bios.

To determine if cpu vt extensions are enabled in bios, do following:

1) Install cpu-checker
```
$ sudo apt-get update
$ sudo apt-get install cpu-checker
```
2) Then check:
```
$ kvm-ok
```
3) If the CPU is enabled, you should see something like:
```
INFO: /dev/kvm exists
KVM acceleration can be used
```
4) Otherwise, you might see something like:
```
INFO: /dev/kvm does not exist
HINT:   sudo modprobe kvm_intel
INFO: Your CPU supports KVM extensions
INFO: KVM (vmx) is disabled by your BIOS
HINT: Enter your BIOS setup and enable Virtualization Technology (VT),
      and then hard poweroff/poweron your system
KVM acceleration can NOT be used
```
## Prerequisite
At first install vagrant and virtualbox. You can do it by official instruction: https://www.vagrantup.com/docs/installation/ and https://www.virtualbox.org/wiki/Downloads

Checked with:
Vagrant 1.9.7
VirtualBox 5.0.40
Ubuntu 16.04/17.04

## Launch
Clone git repository
```
$ git clone https://github.com/bwsw/sj-demo-vagrant.git
$ cd sj-demo-vagrant
```
Launch vagrant:
```
vagrant up
```
It takes up to half an hour, 8GB mem and 7 cpus

At the end of deploying you can see urls of all services.

## Destroy
To destroy vagrant use:
```
vagrant destroy
```

## Description
Vagrant create five ubuntu/xenial64 VMs. <br />
All VMs launched in private network 192.168.50.0 <br />
Also you can access vm with vagrant ssh <name> <br />

Master VM: <br />
name = master <br />
hostname = master <br />
Resources: 
- 2 cpus 
- 1GB memory
- ip = 192.168.50.51
- forwarded ports: 2181, 5050, 8080
Services:
- zookeeper
- master
- marathon
Note:
After VM launched, vagrant installs docker engine and firstly runs zookeeper in docker. 
Next, launches mesos-master service with following configuration: ip=0.0.0.0, advertise_ip=192.168.50.51, hostname=192.168.50.51, zk=zk://192.168.50.51:2181/mesos. 
Next, launches marathon service with following configuration: hostname=192.168.50.51, master=zk://192.168.50.51:2181/mesos, zk=zk://192.168.50.51:2181/marathon.

Slave1 VM: <br /> 
name = slave1 <br />
hostname = slave1 <br />
Resources:
- 2 cpus
- 3GB memory
- ip = 192.168.50.52
- forwarded ports: 5051, 8888, 9092, 7203, 31071, 5601, 9200, 9300
Services:
- mesos-slave
- elasticsearch
- kibana
- sj-rest
- t-streams transaction server
- kafka
Note:
After VM launched, vagrant firstly launches mesos-slave with following configuration: ip=0.0.0.0, advertise_ip=192.168.50.52, hostname=192.168.50.52, zk=zk://192.168.50.51:2181/mesos, ports=forwarded ports.
Next installs docker engine and launches elasticsearch and kibana in docker.

Slave2 VM: <br />
name = slave2 <br />
hostname = slave2 <br />
Resources:
- 1 cpus
- 2GB memory
- ip = 192.168.50.53
- forwarded ports: 31500 - 31600
Services:
- mesos-slave
Note:
After VM launched, vagrant firstly launches mesos-slave with following configuration: ip=0.0.0.0, advertise_ip=192.168.50.53, hostname=192.168.50.53, zk=zk://192.168.50.51:2181/mesos, ports=forwarded ports.
Next installs docker engine.

Storage VM: <br />
name = storage <br />
Resource:
- 1 cpus
- 512MB memory
- ip = 192.168.50.55
- forwarded ports: 27017
Srevices:
- mongo
Note:
After VM launched, vagrant firstly installs docker engine and launches mongo in docker.

Executor VM: <br />
name = executor <br />
Resource:
- 1 cpus
- 200MB memory
- ip = 192.168.50.54
- forwarded ports: 
Note:
This VM used to launch services and create entities.
After VM launched, vagrant firstly launches services on marathon: sj-rest, kafka, tts.
After services launched, vagrant creates all entities via sj-rest.

List of used ports: <br />
8080 - Marathon <br />
5050 - Master <br />
5051 - Agent <br />
8888 - SJ Rest <br />
27017 - Mongo <br />
2181 - Zookeeper <br />
9200,9300 - Elasticsearch <br />
5601 - Kibana <br />
9092,7203 - Kafka <br />
31071 - T-streams Transaction Server <br />
