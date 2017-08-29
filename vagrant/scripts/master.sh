#!/usr/bin/env bash

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF
echo "deb http://repos.mesosphere.com/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/mesosphere.list

sudo apt-get update

sudo apt-get install -y mesos marathon

echo "zk://192.168.50.51:2181/mesos" | sudo tee /etc/mesos/zk

echo 0.0.0.0 | sudo tee /etc/mesos-master/ip
echo 192.168.50.51 | sudo tee /etc/mesos-master/advertise_ip
sudo cp /etc/mesos-master/advertise_ip /etc/mesos-master/hostname

sudo mkdir -p /etc/marathon/conf
sudo cp /etc/mesos-master/hostname /etc/marathon/conf/hostname
cp /etc/mesos/zk /etc/marathon/conf/master
echo "zk://192.168.50.51:2181/marathon" | sudo tee /etc/marathon/conf/zk

echo manual | sudo tee /etc/init/mesos-slave.override

sudo service zookeeper stop
sudo service mesos-master restart
sudo service marathon restart