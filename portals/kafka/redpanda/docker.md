# Docker

This hands-on example uses [<mark style="color:blue;">Ockam</mark>](../../../) to send end-to-end encrypted messages to Redpanda.

We connect a Kafka consumer and a producer, in one virtual private network, with a Redpanda server in another virtual private network. The example uses docker and docker compose to create these virtual networks.

To understand the details of how end-to-end trust is established, and how the portal works even though the two networks are isolated with no exposed ports, please read:  “[<mark style="color:blue;">How does Ockam work?</mark>](../../../how-does-ockam-work.md)”



<figure><img src="../../../.gitbook/assets/redpanda_docker.png" alt=""><figcaption></figcaption></figure>

### Run

This example requires Bash, Git, Curl, Docker, and Docker Compose. Please set up these tools for your operating system, then run the following commands:

```bash
# Clone the Ockam repo from Github.
git clone --depth 1 https://github.com/build-trust/ockam && cd ockam

# Navigate to this example’s directory.
cd examples/command/portals/kafka/redpanda/docker/

# Run the example, use Ctrl-C to exit at any point.
./run.sh
```

If everything runs as expected, you'll see the message: _The example run was successful 🥳_

### Walkthrough

The [<mark style="color:blue;">run.sh script</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh), that you ran above, and its [<mark style="color:blue;">accompanying files</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker) are full of comments and meant to be read. The example setup is only a few simple steps, so please take some time to read and explore.

#### Administrator

* The [<mark style="color:blue;">run.sh script</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh) calls the [<mark style="color:blue;">run function</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L15) which invokes the [<mark style="color:blue;">enroll command</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L29) to create an new identity, sign into Ockam Orchestrator, set up a new Ockam project, make you the administrator of this project, and get a project membership [<mark style="color:blue;">credential</mark>](../../../reference/protocols/identities.md#credentials).
* The run function then [<mark style="color:blue;">generates three new enrollment tickets</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L31-L45). The tickets are valid for 10 minutes. Each ticket can be redeemed only once and assigns <mark style="color:blue;">attributes</mark> to its redeemer. The [<mark style="color:blue;">first ticket</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/docker/run.sh#L30-L39) is meant for the Ockam node that will run in Redpanda Operator’s network. The [<mark style="color:blue;">second and third tickets</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/docker/run.sh#L41-L48) are meant for the Ockam node that will run in Application Team’s network.
* In a typical production setup an administrator or provisioning pipeline generates enrollment tickets and gives them to nodes that are being provisioned. In our example, the run function is acting on your behalf as the administrator of the Ockam project. It uses [<mark style="color:blue;">environment variables to give tickets</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/docker/run.sh#L55C28-L55C65) to and provision Ockam nodes in Redpanda Operator’s and Application Team’s network.
* The run function takes the enrollment tickets, sets them as the value of an [<mark style="color:blue;">environment variable</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/docker/run.sh#L55C28-L55C65), and [<mark style="color:blue;">invokes docker-compose</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/docker/run.sh#L50-L65) to create Redpanda Operator’s and Application Teams’s networks.

#### Redpanda Operator

```yaml
# Create a dedicated and isolated virtual network for redpanda_operator.
networks:
  redpanda_operator:
    driver: bridge
```

* Redpanda Operator’s [<mark style="color:blue;">docker-compose configuration</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/docker/bank\_corp/docker-compose.yml) is used when run.sh invokes docker-compose. It creates an [<mark style="color:blue;">isolated virtual network</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/docker/bank\_corp/docker-compose.yml#L3-L6) for Redpanda Operator.
* In this network, docker compose starts a [<mark style="color:blue;">container with a</mark> ](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/docker/bank\_corp/docker-compose.yml#L9-L17)<mark style="color:blue;">Redpanda event store</mark>. This container becomes available at <mark style="background-color:yellow;">redpanda:9092</mark> in the Redpanda Operator network.
* In the same network, a Redpanda console container is started, connecting directly to <mark style="background-color:yellow;">redpanda:9092</mark>.
* In the Ockam container, the entrypoint creates the Ockam node described by `ockam.yaml`. The node will automatically create an identity,  [<mark style="color:blue;">enroll with your project</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/docker/bank\_corp/run\_ockam.sh#L6-L19), and setup Kafka inlet and outlet.
* The entrypoint script then [<mark style="color:blue;">creates a node that uses</mark> ](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/docker/bank\_corp/run\_ockam.sh#L21-L33)this identity and membership credential to authenticate and create a <mark style="color:blue;">relay</mark> in the project, back to the node, at <mark style="background-color:yellow;">relay address: redpanda</mark>. The run function [<mark style="color:blue;">gave the enrollment ticket permission</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/docker/run.sh#L39C44-L39C60) to use this relay address.

#### Application Teams

```yaml
# Create a dedicated and isolated virtual network for analysis_corp.
networks:
  analysis_corp:
    driver: bridge
```

* Application Teams’s [<mark style="color:blue;">docker-compose configuration</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/docker/analysis\_corp/docker-compose.yml) is used when run.sh invokes docker-compose. It creates an [<mark style="color:blue;">isolated virtual network</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/docker/analysis\_corp/docker-compose.yml#L3-L6) for Application Teams. In this network, docker compose starts a Kafka consumer container and a Kafka producer container.
* The Kafka consumer node container is created using [<mark style="color:blue;">this dockerfile</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/docker/ockam.dockerfile) and this [<mark style="color:blue;">entrypoint script</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/docker/analysis\_corp/run\_ockam.sh). The enrollment ticket from run.sh is [<mark style="color:blue;">passed to the container</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/docker/analysis\_corp/docker-compose.yml#L18) via environment variable.
* When the Kafka consumer node container starts in the Application Teams network, it runs [<mark style="color:blue;">its entrypoint</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/docker/analysis\_corp/run\_ockam.sh)<mark style="color:blue;">.</mark> The entrypoint creates the Ockam node described by `ockam.yaml`. The node will automatically create an identity,  [<mark style="color:blue;">enroll with your project</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/databases/postgres/docker/bank\_corp/run\_ockam.sh#L6-L19), and setup Kafka inlet.
* Next, the entrypoint at the end executes the command present in the docker-compose configuration, which launches a Kafka consumer waiting for messages in the <mark style="background-color:yellow;">demo</mark> topic. Once the messages are received, they are printed out.
* In the producer container the process is analogous, once the Ockam node is setup the command within docker-compose configuration launches a Kafka producer, sending 5 messages, each every 5 seconds.

### Recap

We connected a Kafka consumer and a producer, in one virtual private network with a Redpanda event storage in another virtual private network over an end-to-end encrypted portal.

Messages produced by are always encrypted before leaving the node, and the Redpanda event storage only holds encrypted messages.

Sensitive business data in the Redpanda event storage can only be decrypted by Application Teams. Every communication is <mark style="color:blue;">encrypted</mark> with strong forward secrecy as it moves through the Internet. The communication channel is <mark style="color:blue;">mutually authenticated</mark> and <mark style="color:blue;">authorized</mark>. Keys and credentials are automatically rotated. Access to connect with Redpanda can be easily revoked.

Application Teams. does not get unfettered access to Redpanda Operator’s network. It gets access only to run queries on the Redpanda server. Redpanda Operator does not get unfettered access to Application Teams’s network. It gets access only to respond to queries over a tcp connection. Redpanda Operator cannot initiate connections.

All <mark style="color:blue;">access controls</mark> are secure-by-default. Only project members, with valid credentials, can connect with each other. NAT’s are traversed using a relay and outgoing tcp connections. Redpanda Operator or Application Teams don’t expose any listening endpoints on the Internet. Their networks are completely closed and protected from any attacks from the Internet.

### Cleanup

To delete all containers and images:

```sh
./run.sh cleanup
```



