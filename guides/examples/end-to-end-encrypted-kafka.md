---
description: End-to-end encrypt Kafka producers and consumers
---

# End-to-end encrypted Kafka

We're currently building this integration, if you'd like early access to a beta please [contact us](https://www.ockam.io/contact/form).

Here’s a peek at what that would look like:

#### Administrator

```bash
ockam enroll
ockam project addon configure confluent --bootstrap-server YOUR_CONFLUENT_CLOUD_BOOTSTRAP_SERVER_ADDRESS
ockam project information default --output json > project.json

ockam project enroll --attribute role=member > consumer.token
ockam project enroll --attribute role=member > producer1.token
ockam project enroll --attribute role=member > producer2.token

cat > kafka.config <<EOF
request.timeout.ms=30000
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
        username="YOUR_CONFLUENT_CLOUD_USER_NAME" \
        password="YOUR_CONFLUENT_CLOUD_PASSWORD";
EOF
```

#### Consumer

Copy over `kafka.config`, `project.json`, and  `consumer.token`

```bash
ockam identity create consumer
ockam project authenticate --project-path project.json --identity consumer --token $(cat consumer.token)
ockam node create consumer --project project.json --identity consumer

ockam service start kafka-consumer --node consumer --project-route /project/default --bootstrap-server-ip 127.0.0.1 --bootstrap-server-port 4000 --brokers-port-range 4001-4100

kafka-topics.sh --bootstrap-server localhost:4000 --command-config kafka.config --create --topic m4 --partitions 3
kafka-console-consumer.sh --topic m4 --bootstrap-server localhost:4000 --consumer.config kafka.config
```

#### Producer1

Copy over `kafka.config`, `project.json`, and  `producer1.token`

```
ockam identity create producer1
ockam project authenticate --project-path project.json --identity producer1  --token $(cat producer1.token)
ockam node create producer1 --project project.json --identity producer1

ockam service start kafka-producer --node producer1 --project-route /project/default --bootstrap-server-ip 127.0.0.1 --bootstrap-server-port 5000 --brokers-port-range 5001-5100

kafka-console-producer.sh --topic m4 --bootstrap-server localhost:5000 --producer.config kafka.config
```

#### Producer2

Copy over `kafka.config`, `project.json`, and  `producer2.token`

```
ockam identity create producer2
ockam project authenticate --project-path project.json --identity producer2 --token $(cat producer2.token)
ockam node create producer2 --project project.json --identity producer2

ockam service start kafka-producer --node producer2 --project-route /project/default --bootstrap-server-ip 127.0.0.1 --bootstrap-server-port 6000 --brokers-port-range 6001-6100

kafka-console-producer.sh --topic m4 --bootstrap-server localhost:6000 --producer.config kafka.config
```

