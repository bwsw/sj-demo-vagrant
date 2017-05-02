### Deploy SJ via Vagrant
At first install vagrant and virtualbox. You can do it by official instruction: https://www.vagrantup.com/docs/installation/ and https://www.virtualbox.org/wiki/Downloads

Clone git repository
```
git clone https://github.com/bwsw/sj-demo-vagrant.git
cd sj-demo-vagrant
```

Launch vagrant:
```
vagrant up
```

At the end of deploying you can see urls on all services.

To destroy vagrant use:
```
vagrant destroy
```

Also you can turn it off and after a while turn it on again. All services will work.

### Description
Vagrant create ubuntu/xenial64 VM with 4 cpus, 8 GB memory and 10 GB disk space.
In VM launching mesos with all required services on docker swarm via docker stack deploy.

List of used ports: \
8080 - Marathon \
5050 - Master \
5051 - Agent \
8888 - SJ Rest \
27017 - Mongo \
2181 - Zookeeper \
9200,9300 - Elasticsearch \
5601 - Kibana \
3000-3003 - Aerospike \
9042 - Cassandra \
9092,7203 - Kafka

You can change ports by editing Vagrantfile.
