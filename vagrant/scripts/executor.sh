#!/usr/bin/env bash

#curl -s -X POST http://192.168.50.51:8080/v2/apps -H "Content-type: application/json" -d @services/mongo.json
#sleep 5
#curl -s -X POST http://192.168.50.51:8080/v2/apps -H "Content-type: application/json" -d @services/elasticsearch.json
curl -s -X POST http://192.168.50.51:8080/v2/apps -H "Content-type: application/json" -d @services/sj-rest.json
sleep 5
curl -s -X POST http://192.168.50.51:8080/v2/apps -H "Content-type: application/json" -d @services/kafka.json
sleep 5
#curl -s -X POST http://192.168.50.51:8080/v2/apps -H "Content-type: application/json" -d @servcies/kibana.json
#sleep 5
curl -s -X POST http://192.168.50.51:8080/v2/apps -H "Content-type: application/json" -d @services/tts.json

sleep 30

address=192.168.50.52:8888

curl -s --form jar=@sj-mesos-framework.jar http://$address/v1/custom/jars
curl -s --form jar=@sj-input-streaming-engine.jar http://$address/v1/custom/jars
curl -s --form jar=@sj-regular-streaming-engine.jar http://$address/v1/custom/jars
curl -s --form jar=@sj-output-streaming-engine.jar http://$address/v1/custom/jars

sleep 10

curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"session-timeout\",\"value\": \"7000\",\"domain\": \"configuration.apache-zookeeper\"}"
curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"current-framework\",\"value\": \"com.bwsw.fw-1.0\",\"domain\": \"configuration.system\"}"

curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"crud-rest-host\",\"value\": \"192.168.50.52\",\"domain\": \"configuration.system\"}"
curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"crud-rest-port\",\"value\": \"8888\",\"domain\": \"configuration.system\"}"

curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"marathon-connect\",\"value\": \"http://192.168.50.51:8080\",\"domain\": \"configuration.system\"}"
curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"marathon-connect-timeout\",\"value\": \"60000\",\"domain\": \"configuration.system\"}"
curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"kafka-subscriber-timeout\",\"value\": \"100\",\"domain\": \"configuration.system\"}"
curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"low-watermark\",\"value\": \"100\",\"domain\": \"configuration.system\"}"

curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"regular-streaming-validator-class\",\"value\": \"com.bwsw.sj.crud.rest.instance.validator.RegularInstanceValidator\",\"domain\": \"configuration.system\"}"
curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"input-streaming-validator-class\",\"value\": \"com.bwsw.sj.crud.rest.instance.validator.InputInstanceValidator\",\"domain\": \"configuration.system\"}"
curl -s --request POST "http://$address/v1/config/settings" -H 'Content-Type: application/json' --data "{\"name\": \"output-streaming-validator-class\",\"value\": \"com.bwsw.sj.crud.rest.instance.validator.OutputInstanceValidator\",\"domain\": \"configuration.system\"}"