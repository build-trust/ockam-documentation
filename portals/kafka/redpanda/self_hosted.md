---
layout:
  title:
    visible: true
  description:
    visible: false
  tableOfContents:
    visible: true
  outline:
    visible: true
  pagination:
    visible: true
---

# Self Hosted

In this hands-on example we send end-to-end encrypted messages _through_ Redpanda.

[<mark style="color:blue;">Ockam</mark>](<../../../README (1).md>) encrypts messages from a Producer all-of-the-way to a _specific_ Consumer. Only that _specific_ Consumer can decrypt these messages. This guarantees that your data cannot be observed or tampered with as it passes through Redpanda or the network where it is hosted. The operators of Redpanda can only see encrypted data in the network and in service that they operate. Thus, a compromise of the operator's infrastructure will not compromise the data stream's security, privacy, or integrity.

To learn how end-to-end trust is established, please read: “[<mark style="color:blue;">How does Ockam work?</mark>](../../../how-does-ockam-work.md)”

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

* The [<mark style="color:blue;">run.sh script</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh) calls the [<mark style="color:blue;">run function</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L15) which invokes the [<mark style="color:blue;">enroll command</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L29) to create an new identity, sign in to Ockam Orchestrator, set up a new Ockam project, make you the administrator of this project, and get a project membership [<mark style="color:blue;">credential</mark>](../../../reference/protocols/identities.md#credentials).
* The run function then [<mark style="color:blue;">generates three new enrollment tickets</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L31-L46), each valid for 10 minutes, and can be redeemed only once. The [<mark style="color:blue;">first ticket</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L30-L39) is meant for the Ockam node that will run in Redpanda Operator’s network. The [<mark style="color:blue;">second and third tickets</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L41-L48) are meant for the Consumer and Producer, in the Ockam node that will run in Application Team’s network.
* In a typical production setup, an administrator or provisioning pipeline generates enrollment tickets and gives them to nodes that are being provisioned. In our example, the run function is acting on your behalf as the administrator of the Ockam project. It provisions Ockam nodes in [<mark style="color:blue;">Redpanda Operator’s network</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L53C31-L53C73) and [<mark style="color:blue;">Application Team’s network</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L60C33-L60C158), passing them their tickets using environment variables.
* The run function takes the enrollment tickets, sets them as the value of an [<mark style="color:blue;">environment variable</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L53C36-L53C53), and [<mark style="color:blue;">invokes docker-compose</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L48-L60) to create Redpanda Operator’s and Application Team’s networks.

#### Redpanda Operator

```yaml
# Create a dedicated and isolated virtual network for redpanda_operator.
networks:
  redpanda_operator:
    driver: bridge
```

* Redpanda Operator’s [<mark style="color:blue;">docker-compose configuration</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/redpanda_operator/docker-compose.yml) is used when run.sh invokes docker-compose. It creates an [<mark style="color:blue;">isolated virtual network</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/redpanda_operator/docker-compose.yml#L3-L5) for Redpanda Operator.
* In this network, docker compose starts a [<mark style="color:blue;">container with a Redpanda event store</mark> ](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/redpanda_operator/docker-compose.yml#L23-L58). This container becomes available at <mark style="background-color:yellow;">redpanda:9092</mark> in the Redpanda Operator network.
* In the same network, docker compose also starts a [<mark style="color:blue;">Redpanda console</mark> ](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/redpanda_operator/docker-compose.yml#L59-L81), connecting directly to <mark style="background-color:yellow;">redpanda:9092</mark>. The console will be reachable throughout the example at http://127.0.0.1:8080.
* Once the Redpanda container [<mark style="color:blue;">is ready</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/redpanda_operator/docker-compose.yml#L12C5-L12C27), docker compose starts an [<mark style="color:blue;">Ockam node in a container</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/redpanda_operator/docker-compose.yml#L11-L22) as a companion to the Redpanda container described by `ockam.yaml`, [<mark style="color:blue;">embedded in the script</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/redpanda_operator/run_ockam.sh#L7-L17). The node will automatically create an identity, [<mark style="color:blue;">enroll with your project</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application_team/run_ockam.sh#L6-L15) using the ticket [<mark style="color:blue;">passed to the container</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/redpanda_operator/docker-compose.yml#L19), and set up Kafka outlet.
* The Ockam node then uses this identity and membership credential to authenticate and create a <mark style="color:blue;">relay</mark> in the project, back to the node, at <mark style="background-color:yellow;">relay: redpanda</mark>. The run function [<mark style="color:blue;">gave the enrollment ticket permission</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L38C86-L38C102) to use this relay address.

#### Application Team

```yaml
# Create a dedicated and isolated virtual network for application_team.
networks:
  application_team:
      driver: bridge
```

* Application Team’s [<mark style="color:blue;">docker-compose configuration</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application_team/docker-compose.yml) is used when run.sh invokes docker-compose. It creates an [<mark style="color:blue;">isolated virtual network</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application_team/docker-compose.yml#L3-L5) for the Application Team. In this network, docker compose starts a [<mark style="color:blue;">Kafka Consumer container</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application_team/docker-compose.yml#L7-L49) and a [<mark style="color:blue;">Kafka Producer container</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application_team/docker-compose.yml#L50-L82).
* The Kafka consumer node container is created using [<mark style="color:blue;">this dockerfile</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application_team/kafka_client.dockerfile) and this [<mark style="color:blue;">entrypoint script</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application_team/run_ockam.sh). The consumer enrollment ticket from run.sh is [<mark style="color:blue;">passed to the container</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application_team/docker-compose.yml#L19) via environment variable.
* When the Kafka consumer node container starts in the Application Team's network, it runs [<mark style="color:blue;">its entrypoint</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application_team/run_ockam.sh)<mark style="color:blue;">.</mark> The entrypoint creates the Ockam node described by `ockam.yaml`, [<mark style="color:blue;">embedded in the script</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application_team/run_ockam.sh#L7-L15). The node will automatically create an identity, [<mark style="color:blue;">enroll with your project</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application_team/run_ockam.sh#L6-L15), and setup Kafka inlet.
* Next, the entrypoint at the end executes the [<mark style="color:blue;">command present in the docker-compose configuration</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application_team/docker-compose.yml#L25-L49), which launches a Kafka consumer waiting for messages in the <mark style="background-color:yellow;">demo</mark> topic. Once the messages are received, they are printed out.
* In the producer container, the process is analogous, once the Ockam node is set up the [<mark style="color:blue;">command within docker-compose configuration</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application_team/docker-compose.yml#L61-L82) launches a Kafka producer that sends messages.
* You can view the Redpanda console available at http://127.0.0.1:8080 to see the encrypted messages

### Recap

We sent end-to-end encrypted messages _through_ Redpanda.

Messages are encrypted with strong forward secrecy as soon as they leave a Producer, and only the intended Consumer can decrypt those messages. Redpanda and other Consumers can only see encrypted messages.

All communication is mutually authenticated and authorized. Keys and credentials are automatically rotated. Access can be easily revoked.

### Cleanup

To delete all containers and images:

```sh
./run.sh cleanup
```
