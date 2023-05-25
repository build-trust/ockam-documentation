---
description: >-
  Guarantee authenticity and integrity of events from many producers all-the-way
  to end consumers. End-to-end encryption protects your data as it moves through
  Kafka.
---

# End-to-end encryption through Kafka

Kafka deployments typically combine authentication tokens and Transport Layer Security (TLS) to protect data moving into and out of Kafka topics. While this does secure data in transit over the Internet, it doesn't provide a complete solution to securing data as it travels _through_ Kafka. The Kafka broker will be able to temporarily see the plaintext data.

Encrypting communication both into and out of your Kafka broker combined with encryption of data at rest, inside Kafka, won't be sufficient protection from a data breach if the Kafka broker or the infrastructure it is running on is compromised, as the plaintext data and the keys to decrypt the data are available in memory.

Ockam solves these problems, while providing additional risk mitigating benefits and data integrity assurances, via the Confluent add-on for Ockam Orchestrator.

<figure><img src="../../.gitbook/assets/ockam-end-to-end-encryption-kafka-confluent.gif" alt=""><figcaption><p>End-to-end Encrypted Messages bing written to demo-topic in Kafka in Confluent Cloud</p></figcaption></figure>

### Prerequisites

* [Ockam Command](../../#install)
* [Apache Kafka and Kafka Command Line tools](https://kafka.apache.org/quickstart)
* A Confluent Cloud account

### The setup

We'll start by enrolling with the Orchestrator and ensuring the default project is setup for us to use:

```bash
ockam enroll
```

#### Configure the Confluent add-on

Configuring your Ockam project to use the Confluent add-on begins by pointing it to your bootstrap server address:

```bash
ockam project addon configure confluent \
    --bootstrap-server YOUR_CONFLUENT_CLOUD_BOOTSTRAP_SERVER_ADDRESS
```

As the administrator of the Ockam project, you're able to control what other identities are allowed to enroll themselves into your project by issuing unique one-time use enrollment tokens. We'll start by creating three separate tokens, one each for two separate producers and one for a single consumer, and we'll save each token to a file so we can move it to another host easily:​

```bash
ockam project ticket --attribute role=member > consumer.token
ockam project ticket --attribute role=member > producer1.token
ockam project ticket --attribute role=member > producer2.token
```

The last configuration file we need to generate is `kafka.config`, which will be where you store the username and password you use to access your cluster on Confluent Cloud:

```bash
cat > kafka.config <<EOF
request.timeout.ms=30000
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
        username="YOUR_CONFLUENT_CLOUD_KAFKA_CLUSTER_API_KEY" \
        password="YOUR_CONFLUENT_CLOUD_KAFKA_CLUSTER_API_SECRET";
EOF
```

#### Consumer

On your consumer node you'll start by creating a new identity (you'll need the [Ockam Command](../../reference/command/#install) installed, so repeat the install instructions if you're doing this on a separate host):

```bash
ockam identity create consumer
```

Copy the `consumer.token` file from the previous section, and then use them to authenticate and enroll this identity into your Ockam project:

```bash
ockam project enroll consumer.token --identity consumer
```

An Ockam node is a way to connect securely connect different services to each other, so we'll create one here that we'll use to communicate through the Confluent Cloud cluster using the identity we just created:

```bash
ockam node create consumer --identity consumer
```

Once that completes we can now expose our Kafka bootstrap server. This is like the remote Kafka bootsrtap server and brokers have become virtually adjacent on `localhost:4000` by default:

```bash
ockam kafka-consumer create --node consumer
```

Copy the `kafka.config` file across, and use it to create a new topic that we'll use for sending messages between the producer and consumer in this demo (in this case we've called the topic `demo-topic`)

```bash
kafka-topics.sh --bootstrap-server localhost:4000 --command-config kafka.config \
  --create --topic demo-topic --partitions 3
```

The final step is to start our consumer script, pointing it to `localhost:4000` as our bootstrap server:

```bash
kafka-console-consumer.sh --topic demo-topic \
  --bootstrap-server localhost:4000 --consumer.config kafka.config
```

The consumer code will push all communication into the Ockam node process that is running on the local host. That local Ockam process will automatically manage the generation of cryptographic keys, establishing a secure channel for communication with any producer nodes, and then subsequently receiving, decrypting, and forwarding on any messages that are received from the broker running on our Confluent Cloud cluster.

#### Producer1

To have messages for our consumer to process, we need to have something producing them. We'll go through a very similar process now but instead create the parts necessary for a producer. We start once again by creating an identity on the producer's host (again, install the Ockam Command on that host if required):

```bash
ockam identity create producer1
```

Copy `producer1.token` file from the earlier section and use it to authenticate and enroll into our Ockam project:

```bash
ockam project enroll producer1.token --identity producer1
```

Create a node and link it to both the project and identity we've created:

```bash
ockam node create producer1 --identity producer1
```

And expose our Kafka bootstrap server on default port `5000` so we can start sending messages through Confluent Cloud:

```bash
ockam kafka-producer create --node producer1
```

Make sure to copy the `kafka.config` file across, and start your producer:

```bash
kafka-console-producer.sh --topic demo-topic \
  --bootstrap-server localhost:5000 --producer.config kafka.config
```

Your existing producer code will now be running, communicating with the broker via the secure portal we've created that has exposed the Kafka bootstrap server and Kafka brokers on local ports, and sending messages through to the consumer that was setup in the previous step. However all message payloads will be transparently encrypted as they enter the node on the producer, and not decrypted until they exit the consumer node. At no point in transit can the broker see the plaintext message payload that was initially sent by the producer.

If you look at the encrypted messages inside Confluent Cloud, they will render as unrecognizable characters like in the following screen capture:

<figure><img src="../../.gitbook/assets/ockam-end-to-end-encryption-kafka-confluent.gif" alt=""><figcaption><p>End-to-end Encrypted Messages bing written to demo-topic in Kafka in Confluent Cloud</p></figcaption></figure>

#### Producer2

Connecting a second product is a matter of repeating the steps above with a new identity and the `producer2.token`. Copy over `kafka.config`, and  `producer2.token` files and run the following commands:

```
ockam identity create producer2
ockam project enroll producer2.token --identity producer2
ockam node create producer2 --identity producer2

ockam kafka-producer create --node producer2 --bootstrap-server 127.0.0.1:6000 --brokers-port-range 6001-6100

kafka-console-producer.sh --topic demo-topic --bootstrap-server localhost:6000 --producer.config kafka.config
```

Your second producer will now have generated its own unique set of cryptographic keys, and will be using them to send data through the Kafka brokers in Confluent Cloud and on to your consumer which will then be able to decrypt it.

### Trust your data-in-motion

In just a few minutes the producers and consumers are seamlessly connected. The final result will look and feel exactly like a traditional Kafka setup, behind the scenes however Ockam has abstracted away a number of important security and integrity improvements:

* **Unique keys per identity**: each consumer and producer generates its own cryptographic keys, and is issued its own unique credentials. They then use these to establish a mutually trusted secure channel between each other. By removing the dependency on a third-party service to store or distribute keys you're able to reduce your vulnerability surface area and eliminate single points of failure.
* **Tamper-proof data transfer**: by pushing control of keys to the edges of the system, where authenticated encryption and decryption occurs, no other parties in the supply-chain are able to modify the data in transit. You can be assured that the data you receive at the consumer is exactly what was sent by your producers. You can also be assured that only authorized producers can write to a topic ensuring that the data in your topic is highly trustworthy. If you have even more stringent requirements you can take control of your credential authority and enforce granular authorization policies.
* **Reduced exposure window**: Ockam secure channels regularly rotate authentication keys and session secrets. This approach means that if one of those session secrets was exposed your total data exposure window is limited to the small duration that secret was in use. Rotating authentication keys means that even when the identity keys of a producer are compromised - no historical data is compromised. You can selectively remove the compromised producer and its data. With centralized shared key distribution approaches there is the risk that all current and historical data can’t be trusted after a breach because it may have been tampered with or stolen. Ockam's approach eliminates the risk of compromised historical data and minimizes the risk to future data using automatically rotating keys.


<!-- bats start ENROLLED_HOME -->
<!--
# Ockam binary to use
if [[ -z $OCKAM ]]; then
  OCKAM=ockam
fi

if [[ -z $BATS_LIB ]]; then
  BATS_LIB=$(brew --prefix)/lib # macos
fi

if [[ -z $ENROLLED_HOME ]]; then
  exit 1
fi

if [[ -z $CONFLUENT_BOOTSTRAP_SERVER || -z $CONFLUENT_API_SECRET || -z $CONFLUENT_API_KEY ]]; then
  exit 1
fi

export OCKAM_HOME_CONSUMER=$(mktemp -d)
export OCKAM_HOME_PRODUCER_1=$(mktemp -d)
export OCKAM_HOME_PRODUCER_2=$(mktemp -d)

setup() {
  load "$BATS_LIB/bats-support/load.bash"
  load "$BATS_LIB/bats-assert/load.bash"

  OCKAM_HOME=$ENROLLED_HOME $OCKAM project addon configure confluent \
    --bootstrap-server $CONFLUENT_BOOTSTRAP_SERVER

  OCKAM_HOME=$ENROLLED_HOME $OCKAM project ticket --attribute role=member > consumer.token
  OCKAM_HOME=$ENROLLED_HOME $OCKAM project ticket --attribute role=member > producer1.token
  OCKAM_HOME=$ENROLLED_HOME $OCKAM project ticket --attribute role=member > producer2.token


cat > kafka.config <<EOF
request.timeout.ms=30000
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
        username="$CONFLUENT_API_KEY" \
        password="$CONFLUENT_API_SECRET";
EOF
}

teardown() {
  kafka-topics.sh --bootstrap-server localhost:4000 --command-config kafka.config --delete --topic demo-topic
  rm consumer.token producer1.token producer2.token kafka.config consumer.out

  if consumer_pid=$(cat consumer.pid); then
    kill $consumer_pid
    rm consumer.pid
  fi

  OCKAM_HOME="$ENROLLED_HOME" $OCKAM node delete --all
  OCKAM_HOME="$OCKAM_HOME_CONSUMER" $OCKAM node delete --all
  OCKAM_HOME="$OCKAM_HOME_PRODUCER_1" $OCKAM node delete --all
  OCKAM_HOME="$OCKAM_HOME_PRODUCER_2" $OCKAM node delete --all
}

start_consumer_listener() {
  kafka-console-consumer.sh --topic demo-topic \
    --bootstrap-server localhost:4000 --consumer.config kafka.config > consumer.out 2>&1 &

  consumer_pid="$!"
  echo "$consumer_pid" > consumer.pid
}


@test "test end-to-end encryption with kafka" {
  # Consumer
  run bash -c "OCKAM_HOME=$OCKAM_HOME_CONSUMER $OCKAM identity create consumer"
  assert_success
  run bash -c "OCKAM_HOME=$OCKAM_HOME_CONSUMER $OCKAM project enroll consumer.token --identity consumer"
  assert_success

  run bash -c "OCKAM_HOME=$OCKAM_HOME_CONSUMER $OCKAM node create consumer --identity consumer"
  run bash -c "OCKAM_HOME=$OCKAM_HOME_CONSUMER $OCKAM kafka-consumer create --node consumer"
  assert_success

  run kafka-topics.sh --bootstrap-server localhost:4000 --command-config kafka.config \
    --create --topic demo-topic --partitions 3
  assert_success

  start_consumer_listener
  assert_success


  # Producer 1
  run bash -c "OCKAM_HOME=$OCKAM_HOME_PRODUCER_1 $OCKAM identity create producer1"
  run bash -c "OCKAM_HOME=$OCKAM_HOME_PRODUCER_1 $OCKAM project enroll producer1.token --identity producer1"
  assert_success

  run bash -c "OCKAM_HOME=$OCKAM_HOME_PRODUCER_1 $OCKAM node create producer1 --identity producer1"
  run bash -c "OCKAM_HOME=$OCKAM_HOME_PRODUCER_1 $OCKAM kafka-producer create --node producer1"
  assert_success

  run bash -c "echo 'Hello from producer 1' | kafka-console-producer.sh --topic demo-topic\
    --bootstrap-server localhost:5000 --producer.config kafka.config"
  assert_success

  run cat consumer.out
  assert_output "Hello from producer 1"


  # Producer 2
  run bash -c "OCKAM_HOME=$OCKAM_HOME_PRODUCER_2 $OCKAM identity create producer2"
  run bash -c "OCKAM_HOME=$OCKAM_HOME_PRODUCER_2 $OCKAM project enroll producer2.token --identity producer2"
  assert_success

  run bash -c "OCKAM_HOME=$OCKAM_HOME_PRODUCER_2 $OCKAM node create producer2 --identity producer2"
  run bash -c "OCKAM_HOME=$OCKAM_HOME_PRODUCER_2 $OCKAM kafka-producer create --node producer2 --bootstrap-server 127.0.0.1:6000 --brokers-port-range 6001-6100"
  assert_success

  run bash -c "echo 'Hello from producer 2' | kafka-console-producer.sh --topic demo-topic\
   --bootstrap-server localhost:6000 --producer.config kafka.config"
  assert_success

  run cat consumer.out
  assert_output --partial "Hello from producer 2"
}
-->
<!-- bats end -->
