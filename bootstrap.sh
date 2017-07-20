#!/usr/bin/env bash

# Shell script for deploying sj-platform using minimesos

SJ_VERSION="1.0-SNAPSHOT"
SCALA_VERSION="2.12"

# Check build
if [ -z "$NOT_VAGRANT_BUILD" ]; then
  # Change directory in case of vagrant build
  cd /vagrant
fi



echo "#########################################"
echo "Install dependencies...                 #"
echo "#########################################"
echo ""

#export LANGUAGE=en_US.UTF-8
#export LANG=en_US.UTF-8
#export LC_ALL=en_US.UTF-8
#locale-gen en_US.UTF-8
#dpkg-reconfigure locales

sudo apt-get -y install \
     apt-transport-https \
     ca-certificates \
     curl

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
		 "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
		 $(lsb_release -cs) \
		 stable"

sudo apt-get update
sudo apt-get -y install docker-ce
sudo apt-get -y install openjdk-8-jdk
sudo apt-get -y install git
sudo apt-get -y install openjdk-8*

sudo echo "deb http://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823
sudo apt-get update
sudo apt-get install -y --no-install-recommends sbt
sudo apt-get clean

sudo apt autoclean
sudo rm -rf /var/lib/apt/lists/*
echo ""


echo "#########################################"
echo "INIT DOCKER SWARM                       #"
echo "#########################################"
echo ""
sudo docker swarm init --advertise-addr 192.168.172.17
echo ""


echo "#########################################"
echo "Download and preparing sj-platform      #"
echo "#########################################"
echo ""
git clone -b develop https://github.com/bwsw/sj-platform.git /vagrant/sj-platform
cd sj-platform
sbt sj-mesos-framework/assembly
sbt sj-input-streaming-engine/assembly
sbt sj-regular-streaming-engine/assembly
sbt sj-output-streaming-engine/assembly
cd ..
echo ""


echo "#########################################"
echo "Download and preparing sj-fping-demo    #"
echo "#########################################"
echo ""
git clone -b develop  https://github.com/bwsw/sj-fping-demo.git /vagrant/sj-fping-demo
cd sj-fping-demo
sbt assembly
cd ..
echo ""


#echo ""
#echo "#########################################"
#echo "Get and configure sj-platform           #"
#echo "#########################################"
#echo ""
#wget -O /vagrant/sj-mesos-framework_$SCALA_VERSION-$SJ_VERSION.jar https://oss.sonatype.org/content/repositories/snapshots/com/bwsw/sj-mesos-framework_$SCALA_VERSION/$SJ_VERSION/sj-mesos-framework_$SCALA_VERSION-$SJ_VERSION.jar
#echo ""
#wget -O /vagrant/sj-input-streaming-engine_$SCALA_VERSION-$SJ_VERSION.jar https://oss.sonatype.org/content/repositories/snapshots/com/bwsw/sj-input-streaming-engine_$SCALA_VERSION/$SJ_VERSION/sj-input-streaming-engine_$SCALA_VERSION-$SJ_VERSION.jar
#echo ""
#wget -O /vagrant/sj-regular-streaming-engine_$SCALA_VERSION-$SJ_VERSION.jar https://oss.sonatype.org/content/repositories/snapshots/com/bwsw/sj-regular-streaming-engine_$SCALA_VERSION/$SJ_VERSION/sj-regular-streaming-engine_$SCALA_VERSION-$SJ_VERSION.jar
#echo ""
#wget -O /vagrant/sj-output-streaming-engine_$SCALA_VERSION-$SJ_VERSION.jar https://oss.sonatype.org/content/repositories/snapshots/com/bwsw/sj-output-streaming-engine_$SCALA_VERSION/$SJ_VERSION/sj-output-streaming-engine_$SCALA_VERSION-$SJ_VERSION.jar



echo "#########################################"
echo "Pull docker images                      #"
echo "#########################################"
echo ""
docker pull zookeeper
docker pull mesosphere/mesos-master:1.1.1
docker pull mesosphere/mesos-slave:1.1.1
docker pull mesosphere/marathon:v1.3.5
docker pull mongo
docker pull bwsw/sj-rest:dev
docker pull ches/kafka
docker pull docker.elastic.co/elasticsearch/elasticsearch:5.3.0
docker pull kibana:5.3.0
docker pull bwsw/tstreams-transaction-server
echo ""



echo "#########################################"
echo "Run Docker Stack Mesos                  #"
echo "#########################################"
echo ""

sudo docker stack deploy -c /vagrant/stream-juggler.yml sj

echo "#########################################"
echo "Waiting one minute...                   #"
echo "#########################################"
echo ""
sleep 90
echo ""
sudo docker system prune -f
echo ""



echo "#########################################"
echo "Upload engine jars                      #"
echo "#########################################"
echo ""
address=0.0.0.0:8888
echo ""
curl --form jar=@/vagrant/sj-platform/core/sj-mesos-framework/target/scala-2.12/sj-mesos-framework-$SJ_VERSION.jar http://$address/v1/custom/jars
echo ""
curl --form jar=@/vagrant/sj-platform/core/sj-input-streaming-engine/target/scala-2.12/sj-input-streaming-engine-$SJ_VERSION.jar http://$address/v1/custom/jars
echo ""
curl --form jar=@/vagrant/sj-platform/core/sj-regular-streaming-engine/target/scala-2.12/sj-regular-streaming-engine-$SJ_VERSION.jar http://$address/v1/custom/jars
echo ""
curl --form jar=@/vagrant/sj-platform/core/sj-output-streaming-engine/target/scala-2.12/sj-output-streaming-engine-$SJ_VERSION.jar http://$address/v1/custom/jars
echo ""
rm -rf /vagrant/sj-platform
echo ""



echo "#########################################"
echo "Setup settings for engine               #"
echo "#########################################"
echo ""
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"session-timeout\",\"value\": \"7000\",\"domain\": \"zk\"}"
echo ""
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"current-framework\",\"value\": \"com.bwsw.fw-1.0\",\"domain\": \"system\"}"
echo ""
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"crud-rest-host\",\"value\": \"sj-rest\",\"domain\": \"system\"}"
echo ""
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"crud-rest-port\",\"value\": \"8080\",\"domain\": \"system\"}"
echo ""
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"marathon-connect\",\"value\": \"http://marathon:8080\",\"domain\": \"system\"}"
echo ""
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"marathon-connect-timeout\",\"value\": \"60000\",\"domain\": \"system\"}"
echo ""
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"kafka-subscriber-timeout\",\"value\": \"100\",\"domain\": \"system\"}"
echo ""
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"low-watermark\",\"value\": \"100\",\"domain\": \"system\"}"
echo ""
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"regular-streaming-validator-class\",\"value\": \"com.bwsw.sj.crud.rest.instance.validator.RegularInstanceValidator\",\"domain\": \"system\"}"
echo ""
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"input-streaming-validator-class\",\"value\": \"com.bwsw.sj.crud.rest.instance.validator.InputInstanceValidator\",\"domain\": \"system\"}"
echo ""
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"output-streaming-validator-class\",\"value\": \"com.bwsw.sj.crud.rest.instance.validator.OutputInstanceValidator\",\"domain\": \"system\"}"
echo ""



echo "##########################################"
echo "CREATE PROVIDERS                         #"
echo "##########################################"
echo ""
sed -i 's/176.120.25.19/elasticsearch/g' /vagrant/sj-fping-demo/api-json/providers/elasticsearch-ps-provider.json
curl --request POST "http://$address/v1/providers" -H 'Content-Type: application/json' --data "@/vagrant/sj-fping-demo/api-json/providers/elasticsearch-ps-provider.json"
echo ""
sed -i 's/176.120.25.19/kafka/g' /vagrant/sj-fping-demo/api-json/providers/kafka-ps-provider.json
curl --request POST "http://$address/v1/providers" -H 'Content-Type: application/json' --data "@/vagrant/sj-fping-demo/api-json/providers/kafka-ps-provider.json"
echo ""
sed -i 's/176.120.25.19/zookeeper/g' /vagrant/sj-fping-demo/api-json/providers/zookeeper-ps-provider.json
curl --request POST "http://$address/v1/providers" -H 'Content-Type: application/json' --data "@/vagrant/sj-fping-demo/api-json/providers/zookeeper-ps-provider.json"
echo ""


echo "##########################################"
echo "CREATE SERVICES                          #"
echo "##########################################"
echo ""
curl --request POST "http://$address/v1/services" -H 'Content-Type: application/json' --data "@/vagrant/sj-fping-demo/api-json/services/elasticsearch-ps-service.json"
echo ""
curl --request POST "http://$address/v1/services" -H 'Content-Type: application/json' --data "@/vagrant/sj-fping-demo/api-json/services/kafka-ps-service.json"
echo ""
curl --request POST "http://$address/v1/services" -H 'Content-Type: application/json' --data "@/vagrant/sj-fping-demo/api-json/services/zookeeper-ps-service.json"
echo ""
curl --request POST "http://$address/v1/services" -H 'Content-Type: application/json' --data "@/vagrant/sj-fping-demo/api-json/services/tstream-ps-service.json"
echo ""

echo "##########################################"
echo "DOWNLOAD MODULES                         #"
echo "##########################################"
echo ""
#wget -O /vagrant/ps-output_2.12-1.0-SNAPSHOT.jar https://oss.sonatype.org/content/repositories/snapshots/com/bwsw/ps-output_2.12/1.0-SNAPSHOT/ps-output_2.12-1.0-SNAPSHOT.jar
#echo ""
#wget -O /vagrant/ps-process_2.12-1.0-SNAPSHOT.jar https://oss.sonatype.org/content/repositories/snapshots/com/bwsw/ps-process_2.12/1.0-SNAPSHOT/ps-process_2.12-1.0-SNAPSHOT.jar
#echo ""
wget -O /vagrant/sj-regex-input_$SCALA_VERSION-$SJ_VERSION.jar https://oss.sonatype.org/content/repositories/snapshots/com/bwsw/sj-regex-input_$SCALA_VERSION/$SJ_VERSION/sj-regex-input_$SCALA_VERSION-$SJ_VERSION.jar
echo ""


echo "##########################################"
echo "UPLOAD MODULES                           #"
echo "##########################################"
echo ""
curl --form jar=@/vagrant/sj-regex-input_$SCALA_VERSION-$SJ_VERSION.jar http://$address/v1/modules
echo ""
curl --form jar=@/vagrant/sj-fping-demo/ps-process/target/scala-2.12/ps-process-1.0-SNAPSHOT.jar http://$address/v1/modules
echo ""
curl --form jar=@/vagrant/sj-fping-demo/ps-output/target/scala-2.12/ps-output-1.0-SNAPSHOT.jar http://$address/v1/modules
echo ""



echo "##########################################"
echo "CREATE STREAMS                           #"
echo "##########################################"
echo ""
curl --request POST "http://$address/v1/streams" -H 'Content-Type: application/json' --data "@/vagrant/sj-fping-demo/api-json/streams/echo-response.json"
echo ""
curl --request POST "http://$address/v1/streams" -H 'Content-Type: application/json' --data "@/vagrant/sj-fping-demo/api-json/streams/unreachable-response.json"
echo ""
curl --request POST "http://$address/v1/streams" -H 'Content-Type: application/json' --data "@/vagrant/sj-fping-demo/api-json/streams/echo-response-1m.json"
echo ""
curl --request POST "http://$address/v1/streams" -H 'Content-Type: application/json' --data "@/vagrant/sj-fping-demo/api-json/streams/es-echo-response-1m.json"
echo ""
curl --request POST "http://$address/v1/streams" -H 'Content-Type: application/json' --data "@/vagrant/sj-fping-demo/api-json/streams/fallback-response.json"
echo ""


echo "##########################################"
echo "CREATE INSTANCES                         #"
echo "##########################################"
echo ""
curl --request POST "http://$address/v1/modules/input-streaming/com.bwsw.input.regex/1.0/instance" -H 'Content-Type: application/json' --data "@/vagrant/sj-fping-demo/api-json/instances/pingstation-input.json"
echo ""
curl --request POST "http://$address/v1/modules/regular-streaming/pingstation-process/1.0/instance" -H 'Content-Type: application/json' --data "@/vagrant/sj-fping-demo/api-json/instances/pingstation-echo-process.json"
echo ""
curl --request POST "http://$address/v1/modules/output-streaming/pingstation-output/1.0/instance" -H 'Content-Type: application/json' --data "@/vagrant/sj-fping-demo/api-json/instances/pingstation-output.json"
echo ""
curl --request PUT "http://0.0.0.0:9200/pingstation" -H 'Content-Type: application/json' --data "@/vagrant/sj-fping-demo/api-json/elasticsearch-index.json"
echo ""
rm -rf /vagrant/sj-fping-demo
echo ""


echo "##########################################"
echo "Complete!                                #"
echo "##########################################"
echo ""
echo "Marathon url: http://0.0.0.0:8080/"
echo "Mesos Master url: http://0.0.0.0:5050/"
echo "Mesos Agent url: http://0.0.0.0:5051/"
echo "Sj-rest url: http://0.0.0.0:8888/"
echo "Elasticsearch url: http://0.0.0.0:9200/"
echo "Kibana url: http://0.0.0.0:5601/"
echo ""
echo "Additional"
echo "Mongo address: 0.0.0.0:27017"
echo "Cassandra address: 0.0.0.0:9042"
echo "Kafka address: 0.0.0.0:9092"
echo "Aerospike address: 0.0.0.0:3000"
echo ""