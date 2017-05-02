#!/usr/bin/env bash

# Shell script for deploying sj-platform using minimesos

SJ_VERSION="1.0-SNAPSHOT"
SCALA_VERSION="2.12"

# Check build
if [ -z "$NOT_VAGRANT_BUILD" ]; then
  # Change directory in case of vagrant build
  cd /vagrant
fi

echo "Install dependencies..."
echo ""

echo "Install docker"
echo ""
sudo apt-get -y install \
		 apt-transport-https \
		 ca-certificates \
		 curl \
		 software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
		 "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
		 $(lsb_release -cs) \
		 stable"

sudo apt-get update
sudo apt-get -y install docker-ce

echo "Install JDK 8"
echo ""
sudo apt-get -y install openjdk-8-jdk

echo "Get and configure sj-platform"
echo ""
wget -O sj-transaction-generator_$SCALA_VERSION-$SJ_VERSION.jar https://oss.sonatype.org/content/repositories/snapshots/com/bwsw/sj-transaction-generator_$SCALA_VERSION/$SJ_VERSION/sj-transaction-generator_$SCALA_VERSION-$SJ_VERSION.jar
wget -O sj-mesos-framework_$SCALA_VERSION-$SJ_VERSION.jar https://oss.sonatype.org/content/repositories/snapshots/com/bwsw/sj-mesos-framework_$SCALA_VERSION/$SJ_VERSION/sj-mesos-framework_$SCALA_VERSION-$SJ_VERSION.jar
wget -O sj-input-streaming-engine_$SCALA_VERSION-$SJ_VERSION.jar https://oss.sonatype.org/content/repositories/snapshots/com/bwsw/sj-input-streaming-engine_$SCALA_VERSION/$SJ_VERSION/sj-input-streaming-engine_$SCALA_VERSION-$SJ_VERSION.jar
wget -O sj-regular-streaming-engine_$SCALA_VERSION-$SJ_VERSION.jar https://oss.sonatype.org/content/repositories/snapshots/com/bwsw/sj-regular-streaming-engine_$SCALA_VERSION/$SJ_VERSION/sj-regular-streaming-engine_$SCALA_VERSION-$SJ_VERSION.jar
wget -O sj-output-streaming-engine_$SCALA_VERSION-$SJ_VERSION.jar https://oss.sonatype.org/content/repositories/snapshots/com/bwsw/sj-output-streaming-engine_$SCALA_VERSION/$SJ_VERSION/sj-output-streaming-engine_$SCALA_VERSION-$SJ_VERSION.jar

echo "Pull docker images"
echo ""
dokcer pull zookeeper
docker pull mesosphere/mesos-master:1.1.1
docker pull mesosphere/mesos-slave:1.1.1
docker pull mesosphere/marathon
docker pull mongo
docker pull bwsw/sj-rest:dev
docker pull cassandra
docker pull ches/kafka
docker pull aerospike
docker pull docker.elastic.co/elasticsearch/elasticsearch:5.3.0
docker pull kibana:5.3.0

echo "Run Docker Stack Mesos"
echo ""
# sudo sysctl -w vm.max_map_count=262144
sudo docker swarm init
sudo docker stack deploy -c stream-juggler.yml sj
sleep 60

echo "Upload engine jars"
echo ""
address=0.0.0.0:8888

curl --form jar=@sj-transaction-generator_$SCALA_VERSION-$SJ_VERSION.jar http://$address/v1/custom/jars
curl --form jar=@sj-mesos-framework_$SCALA_VERSION-$SJ_VERSION.jar http://$address/v1/custom/jars
curl --form jar=@sj-input-streaming-engine_$SCALA_VERSION-$SJ_VERSION.jar http://$address/v1/custom/jars
curl --form jar=@sj-regular-streaming-engine_$SCALA_VERSION-$SJ_VERSION.jar http://$address/v1/custom/jars
curl --form jar=@sj-output-streaming-engine_$SCALA_VERSION-$SJ_VERSION.jar http://$address/v1/custom/jars

echo "Setup settings for engine"
echo ""
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"session-timeout\",\"value\": \"7000\",\"domain\": \"zk\"}" 
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"current-transaction-generator\",\"value\": \"com.bwsw.tg-1.0\",\"domain\": \"system\"}" 
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"current-framework\",\"value\": \"com.bwsw.fw-1.0\",\"domain\": \"system\"}" 

curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"crud-rest-host\",\"value\": \"0.0.0.0\",\"domain\": \"system\"}" 
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"crud-rest-port\",\"value\": \"8888\",\"domain\": \"system\"}" 

curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"marathon-connect\",\"value\": \"http://0.0.0.0:8080\",\"domain\": \"system\"}" 
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"marathon-connect-timeout\",\"value\": \"60000\",\"domain\": \"system\"}" 
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"transaction-generator-client-retry-period\",\"value\": \"500\",\"domain\": \"system\"}" 
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"transaction-generator-server-retry-period\",\"value\": \"600\",\"domain\": \"system\"}" 
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"transaction-generator-retry-count\",\"value\": \"10\",\"domain\": \"system\"}" 
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"kafka-subscriber-timeout\",\"value\": \"15\",\"domain\": \"system\"}" 

curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"regular-streaming-validator-class\",\"value\": \"com.bwsw.sj.crud.rest.validator.instance.RegularInstanceValidator\",\"domain\": \"system\"}" 
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"input-streaming-validator-class\",\"value\": \"com.bwsw.sj.crud.rest.validator.instance.InputInstanceValidator\",\"domain\": \"system\"}" 
curl --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"output-streaming-validator-class\",\"value\": \"com.bwsw.sj.crud.rest.validator.instance.OutputInstanceValidator\",\"domain\": \"system\"}"

echo ""
echo "Complete!"
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
