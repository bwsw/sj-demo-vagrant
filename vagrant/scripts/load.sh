#!/usr/bin/env bash

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

echo ""
echo "Complete!"
echo "Marathon url: http://192.168.50.51:8080/"
echo "Mesos Master url: http://192.168.50.51:5050/"
echo "Mesos Agent for services url: http://192.168.50.52:5051/"
echo "Mesos Agent for tasks url: http://192.168.50.53:5052"
echo "Sj-rest url: http://192.168.50.52:8888/"
echo "Elasticsearch url: http://192.168.50.52:9200/"
echo "Kibana url: http://192.168.50.52:5601/"
echo ""
echo "Additional"
echo "Mongo address: 192.168.50.55:27017"
echo "Kafka address: 192.168.50.52:9092"
