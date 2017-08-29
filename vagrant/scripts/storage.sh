#!/usr/bin/env bash

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF
echo "deb http://repos.mesosphere.com/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/mesosphere.list

sudo apt-get update

sudo apt-get -y install mesos

echo "zk://192.168.50.51:2181/mesos" | sudo tee /etc/mesos/zk

sudo service zookeeper stop
sudo sh -c "echo manual > /etc/init/zookeeper.override"
sudo service mesos-master stop
sudo sh -c "echo manual > /etc/init/mesos-master.override"

sudo touch /etc/mesos-slave/containerizers
echo "docker,mesos" | sudo tee /etc/mesos-slave/containerizers
echo 0.0.0.0 | sudo tee /etc/mesos-slave/ip
echo 192.168.50.55 | sudo tee /etc/mesos-slave/advertise_ip
echo 192.168.50.55 | sudo tee /etc/mesos-slave/hostname
sudo touch /etc/mesos-slave/resources
echo "cpus:1;mem:768;disk:1024;ports:[27017-27017]" | sudo tee /etc/mesos-slave/resources
sudo service mesos-slave restart
