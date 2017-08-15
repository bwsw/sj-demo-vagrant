# -*- mode: ruby -*-
# vi: set ft=ruby :a


SJ_VERSION="1.0-SNAPSHOT"
SCALA_VERSION="2.12"


#---DOCKER_INSTALL---
$docker_install = <<SCRIPT
sudo apt-get update
sudo apt-get -y install \
  apt-transport-https \
  ca-certificates \
  curl
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable"
sudo apt-get update
sudo apt-get -y install docker-ce
SCRIPT

#---INSTALL_EXTRAS---
$install_extras = <<SCRIPT

SCRIPT


#---MASTER_SCRIPT---
$master_script = <<SCRIPT
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF
echo "deb http://repos.mesosphere.com/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/mesosphere.list

sudo apt-get update

sudo apt-get install -y mesos marathon

echo "zk://192.168.50.51:2181/mesos" | sudo tee /etc/mesos/zk

echo 0.0.0.0 | sudo tee /etc/mesos-master/ip
echo 192.168.50.51 | sudo tee /etc/mesos-master/advertise_ip
sudo cp /etc/mesos-master/ip /etc/mesos-master/hostname
sudo touch
sudo touch /etc/mesos-master/agent_removal_rate_limit
echo "1/1mins" | sudo tee /etc/mesos-master/agent_removal_rate_limit

sudo mkdir -p /etc/marathon/conf
sudo cp /etc/mesos-master/hostname /etc/marathon/conf/hostname
cp /etc/mesos/zk /etc/marathon/conf/master
echo "zk://192.168.50.51:2181/marathon" | sudo tee /etc/marathon/conf/zk

echo manual | sudo tee /etc/init/mesos-slave.override

sudo touch /etc/marathon/conf/task_lost_expunge_interval
echo 10000 | sudo tee /etc/marathon/conf/task_lost_expunge_interval
sudo touch /etc/marathon/conf/task_lost_expunge_initial_delay
echo 10000 | sudo tee /etc/marathon/conf/task_lost_expunge_initial_delay
sudo touch /etc/marathon/conf/task_lost_expunge_gc
echo 10000 | sudo tee /etc/marathon/conf/task_lost_expunge_gc

sudo service zookeeper stop
sudo service mesos-master restart
sudo service marathon restart
SCRIPT


#---SLAVE1_SCRIPT---
$slave1_script = <<SCRIPT
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
sudo touch /etc/mesos-slave/ip
echo 0.0.0.0 | sudo tee /etc/mesos-slave/ip
sudo touch /etc/mesos-slave/advertise_ip
echo 192.168.50.52 | sudo tee /etc/mesos-slave/advertise_ip
sudo touch /etc/mesos-slave/hostname
echo 192.168.50.52 | sudo tee /etc/mesos-slave/hostname
sudo touch /etc/mesos-slave/resources
echo "cpus:2;mem:4096;disk:1024;ports:[8888-8888];ports:[9092-9092];ports:[7203-7203];ports:[31071-31071]" | sudo tee /etc/mesos-slave/resources
sudo service mesos-slave restart

#Starting elasticsearch on docker
sudo docker run -d --restart=always --name elasticsearch -p 9200:9200 -p 9300:9300 -e http.host=0.0.0.0 -e xpack.security.enabled=false -e transport.host=0.0.0.0 -e cluster.name=elasticsearch docker.elastic.co/elasticsearch/elasticsearch:5.5.1
sudo docker run -d --restart=always --name kibana -p 5601:5601 -e ELASTICSEARCH_URL=http://192.168.50.52:9200 -v kibana_data:/data kibana:5.5.1
SCRIPT

#---SLAVE2_SCRIPT---
$slave2_script = <<SCRIPT
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF
echo "deb http://repos.mesosphere.com/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/mesosphere.list

sudo apt-get update

sudo apt-get -y install mesos

echo "zk://192.168.50.51:2181/mesos" | sudo tee /etc/mesos/zk

sudo service zookeeper stop
sudo sh -c "echo manual > /etc/init/zookeeper.override"
sudo service mesos-master stop
sudo sh -c "echo manual > /etc/init/mesos-master.override"


sudo touch /etc/mesos-slave/resources
echo "cpus:2;mem:3072;disk:1024;ports:[31500-31600]" | sudo tee /etc/mesos-slave/resources
sudo touch /etc/mesos-slave/port
echo 5052 | sudo tee /etc/mesos-slave/port
sudo touch /etc/mesos-slave/containerizers
echo "docker,mesos" | sudo tee /etc/mesos-slave/containerizers
sudo touch /etc/mesos-slave/ip
echo 0.0.0.0 | sudo tee /etc/mesos-slave/ip
sudo touch /etc/mesos-slave/advertise_ip
echo 192.168.50.53 | sudo tee /etc/mesos-slave/advertise_ip
sudo touch /etc/mesos-slave/hostname
sudo cp /etc/mesos-slave/advertise_ip /etc/mesos-slave/hostname
sudo service mesos-slave restart
SCRIPT


#---EXECUTOR---
$executor = <<SCRIPT
#curl -s -X POST http://192.168.50.51:8080/v2/apps -H "Content-type: application/json" -d @services/mongo.json
sleep 5
#curl -s -X POST http://192.168.50.51:8080/v2/apps -H "Content-type: application/json" -d @services/elasticsearch.json
curl -s -X POST http://192.168.50.51:8080/v2/apps -H "Content-type: application/json" -d @services/sj-rest.json
sleep 5
curl -s -X POST http://192.168.50.51:8080/v2/apps -H "Content-type: application/json" -d @services/kafka.json
sleep 5
#curl -s -X POST http://192.168.50.51:8080/v2/apps -H "Content-type: application/json" -d @servcies/kibana.json
sleep 5
curl -s -X POST http://192.168.50.51:8080/v2/apps -H "Content-type: application/json" -d @services/tts.json

sleep 60

address=192.168.50.52:8888

curl -s --form jar=@sj-mesos-framework.jar http://$address/v1/custom/jars
curl -s --form jar=@sj-input-streaming-engine.jar http://$address/v1/custom/jars
curl -s --form jar=@sj-regular-streaming-engine.jar http://$address/v1/custom/jars
curl -s --form jar=@sj-output-streaming-engine.jar http://$address/v1/custom/jars

sleep 30

curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data @/vagrant/config/session-timeout
sleep 2
curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data @/vagrant/config/current-framework
sleep 2
curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data @/vagrant/config/crud-rest-host
sleep 2
curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data @/vagrant/config/crud-rest-port
sleep 2
curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data @/vagrant/config/marathon-connect
sleep 2
curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data @/vagrant/config/marathon-connect-timeout
sleep 2
curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data @/vagrant/config/kafka-subscriber-timeout
sleep 2
curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data @/vagrant/config/low-watermark
sleep 2
curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data @/vagrant/config/regular-streaming-validator-class
sleep 2
curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data @/vagrant/config/input-streaming-validator-class
sleep 2
curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data @/vagrant/config/output-streaming-validator-class
SCRIPT


#---LOAD---
$load = <<SCRIPT
address=192.168.50.52:8888
curl -s --request POST "http://$address/v1/providers" -H 'Content-Type: application/json' --data "@api-json/providers/elasticsearch-ps-provider.json"
sleep 2
curl -s --request POST "http://$address/v1/providers" -H 'Content-Type: application/json' --data "@api-json/providers/kafka-ps-provider.json"
sleep 2
curl -s --request POST "http://$address/v1/providers" -H 'Content-Type: application/json' --data "@api-json/providers/zookeeper-ps-provider.json"
sleep 2
curl -s --request POST "http://$address/v1/services" -H 'Content-Type: application/json' --data "@api-json/services/elasticsearch-ps-service.json"
sleep 2
curl -s --request POST "http://$address/v1/services" -H 'Content-Type: application/json' --data "@api-json/services/kafka-ps-service.json"
sleep 2
curl -s --request POST "http://$address/v1/services" -H 'Content-Type: application/json' --data "@api-json/services/zookeeper-ps-service.json"
sleep 2
curl -s --request POST "http://$address/v1/services" -H 'Content-Type: application/json' --data "@api-json/services/tstream-ps-service.json"
sleep 2
curl -s --form jar=@sj-regex-input.jar http://$address/v1/modules
sleep 2
curl -s --form jar=@ps-process.jar http://$address/v1/modules
sleep 2
curl -s --form jar=@ps-output.jar http://$address/v1/modules
sleep 2
curl -s --request POST "http://$address/v1/streams" -H 'Content-Type: application/json' --data "@api-json/streams/echo-response.json"
sleep 2
curl -s --request POST "http://$address/v1/streams" -H 'Content-Type: application/json' --data "@api-json/streams/unreachable-response.json"
sleep 2
curl -s --request POST "http://$address/v1/streams" -H 'Content-Type: application/json' --data "@api-json/streams/echo-response-1m.json"
sleep 2
curl -s --request POST "http://$address/v1/streams" -H 'Content-Type: application/json' --data "@api-json/streams/es-echo-response-1m.json"
sleep 2
curl -s --request POST "http://$address/v1/streams" -H 'Content-Type: application/json' --data "@api-json/streams/fallback-response.json"
sleep 2
curl -s --request POST "http://$address/v1/modules/input-streaming/com.bwsw.input.regex/1.0/instance" -H 'Content-Type: application/json' --data "@api-json/instances/pingstation-input.json"
sleep 2
curl -s --request POST "http://$address/v1/modules/regular-streaming/pingstation-process/1.0/instance" -H 'Content-Type: application/json' --data "@api-json/instances/pingstation-echo-process.json"
sleep 2
curl -s --request POST "http://$address/v1/modules/output-streaming/pingstation-output/1.0/instance" -H 'Content-Type: application/json' --data "@api-json/instances/pingstation-output.json"
sleep 2
curl -s --request PUT "http://192.168.50.52:9200/pingstation" -H 'Content-Type: application/json' --data "@api-json/elasticsearch-index.json"
SCRIPT



Vagrant.configure("2") do |config|
#  config.vm.box = "ubuntu/xenial64"

#---MASTER_NODE---
  config.vm.define "master" do |master|
    master.vm.box = "ubuntu/xenial64"
    master.ssh.username = "ubuntu"
    master.ssh.password = "cc8fbdab8070bf7bfeb44f55"
    master.vm.network "private_network", ip: "192.168.50.51"
    master.vm.provision "shell", inline: $docker_install
    master.vm.provision "docker" do |d|
      d.pull_images "zookeeper"
      d.run "zookeeper", image: "zookeeper", args: "-e ZOO_MY_ID=1 -e ZOO_SERVERS=0.0.0.0:2888:3888 -p 2181:2181"
    end
    master.vm.provision "shell", inline: $master_script
    master.vm.network :forwarded_port, guest: 2181, host: 2181, auto_correct: true
    master.vm.network :forwarded_port, guest: 5050, host: 5050, auto_correct: true
    master.vm.network :forwarded_port, guest: 8080, host: 8080, auto_correct: true
    master.vm.provider :virtualbox do |vb|
      vb.cpus = 6
      vb.memory = 4096
    end
  end

#---SLAVE1_NODE---
  config.vm.define "slave1" do |slave1|
    slave1.vm.box = "ubuntu/xenial64"
    slave1.ssh.username = "ubuntu"
    slave1.ssh.password = "cc8fbdab8070bf7bfeb44f55"
    slave1.vm.network "private_network", ip: "192.168.50.52"
    slave1.vm.provision "shell", inline: $docker_install
    slave1.vm.provision "shell", inline: $slave1_script
    slave1.vm.network :forwarded_port, guest: 5051, host: 5051, auto_correct: true
    slave1.vm.network :forwarded_port, guest: 8888, host: 8888, auto_correct: true
    slave1.vm.network :forwarded_port, guest: 9092, host: 9092, auto_correct: true
    slave1.vm.network :forwarded_port, guest: 7203, host: 7203, auto_correct: true
    slave1.vm.network :forwarded_port, guest: 31071, host: 31071, auto_correct: true
    slave1.vm.network :forwarded_port, guest: 5601, host: 5601, auto_correct: true
    slave1.vm.network :forwarded_port, guest: 9200, host: 9200, auto_correct: true
    slave1.vm.network :forwarded_port, guest: 9300, host: 9300, auto_correct: true
    slave1.vm.provision "docker" do |d|
#      d.pull_images "mongo"
      d.pull_images "bwsw/sj-rest:dev"
      d.pull_images "ches/kafka"
      d.pull_images "docker.elastic.co/elasticsearch/elasticsearch:5.5.1"
      d.pull_images "kibana:5.5.1"
      d.pull_images "bwsw/tstreams-transaction-server"
    end
    slave1.vm.provider :virtualbox do |vb|
      vb.cpus = 3
      vb.memory = 6144
    end
    slave1.vm.provision "shell", inline: "sudo sysctl -w vm.max_map_count=262144"
    slave1.vm.provision "shell", inline: "echo vm.max_map_count = 262144 >> /etc/sysctl.conf && sysctl -p"
  end

#---SLAVE2_NODE---
  config.vm.define "slave2" do |slave2|
    slave2.vm.box = "ubuntu/xenial64"
    slave2.ssh.username = "ubuntu"
    slave2.ssh.password = "cc8fbdab8070bf7bfeb44f55"
    slave2.vm.network "private_network", ip: "192.168.50.53"
    slave2.vm.provision "shell", inline: $docker_install
    slave2.vm.provision "shell", inline: $slave2_script
    slave2.vm.network :forwarded_port, guest: 5052, host: 5052, auto_correct: true
    for i in 31500..31600
      slave2.vm.network :forwarded_port, guest: i, host: i, auto_correct: false
    end
    slave2.vm.provider :virtualbox do |vb|
      vb.cpus = 3
      vb.memory = 4096
    end
  end

#---STORAGE_NODE---
  config.vm.define "storage" do |storage|
    storage.vm.box = "ubuntu/xenial64"
    storage.ssh.username = "ubuntu"
    storage.ssh.password = "cc8fbdab8070bf7bfeb44f55"
    storage.vm.network "private_network", ip: "192.168.50.55"
    storage.vm.provision "shell", inline: $docker_install
    storage.vm.provision "docker" do |d|
      d.pull_images "mongo"
      d.run "mongo", image: "mongo", args: "-p 27017:27017 --memory 512MB -v mongo_data:/data/db"
    end
    storage.vm.network :forwarded_port, guest: 27017, host: 27017, auto_correct: true
  end

#---EXECUTOR_NODE---
  config.vm.define "executor" do |ex|
    ex.vm.box = "ddpaimon/test"
    ex.ssh.username = "ubuntu"
    ex.ssh.password = "cc8fbdab8070bf7bfeb44f55"
    ex.vm.network "private_network", ip: "192.168.50.54"
    ex.vm.provision "shell", inline: $executor
    ex.vm.provision "shell", inline: $load
    ex.vm.provider :virtualbox do |vb|
      vb.cpus = 1
      vb.memory = 200
    end
  end

end
