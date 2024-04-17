# Docker

Let's use [<mark style="color:blue;">Ockam</mark>](../../../) to send end-to-end encrypted messages _through_ Redpanda.

[<mark style="color:blue;">Ockam</mark>](../../../) encrypts messages from a Producer to a specific Consumer. Only that specific Consumer can decrypt these messages. This guarantees that your data cannot be observed or tampered as it passes through Redpanda. Operators of Redpanda only see end-to-end encrypted data. Any compromise of an operator's infrastructure cannot compromise your business data.

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

* The [<mark style="color:blue;">run.sh script</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh) calls the [<mark style="color:blue;">run function</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L15) which invokes the [<mark style="color:blue;">enroll command</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L29) to create an new identity, sign into Ockam Orchestrator, set up a new Ockam project, make you the administrator of this project, and get a project membership [<mark style="color:blue;">credential</mark>](../../../reference/protocols/identities.md#credentials).
* The run function then [<mark style="color:blue;">generates three new enrollment tickets</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L31-L45). The tickets are valid for 10 minutes. Each ticket can be redeemed only once. The [<mark style="color:blue;">first ticket</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L30-L39) is meant for the Ockam node that will run in Redpanda Operator’s network. The [<mark style="color:blue;">second and third tickets</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L41-L48) are meant for the Ockam node that will run in Application Team’s network.
* In a typical production setup an administrator or provisioning pipeline generates enrollment tickets and gives them to nodes that are being provisioned. In our example, the run function is acting on your behalf as the administrator of the Ockam project. It uses [<mark style="color:blue;">environment variables to give tickets</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L53C28-L53C65) to and provision Ockam nodes in Redpanda Operator’s and Application Team’s network.
* The run function takes the enrollment tickets, sets them as the value of an [<mark style="color:blue;">environment variable</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L53C28-L53C65), and [<mark style="color:blue;">invokes docker-compose</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L53-L60) to create Redpanda Operator’s and Application Teams’s networks.

#### Redpanda Operator

```yaml
# Create a dedicated and isolated virtual network for redpanda_operator.
networks:
  redpanda_operator:
    driver: bridge
```

* Redpanda Operator’s [<mark style="color:blue;">docker-compose configuration</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/redpanda\_operator/docker-compose.yml) is used when run.sh invokes docker-compose. It creates an [<mark style="color:blue;">isolated virtual network</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/redpanda\_operator/docker-compose.yml#L3-L6) for Redpanda Operator.
* In this network, docker compose starts a [<mark style="color:blue;">container with a Redpanda event store</mark> ](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/redpanda\_operator/docker-compose.yml#L20-L48). This container becomes available at <mark style="background-color:yellow;">redpanda:9092</mark> in the Redpanda Operator network.
* In the same network, a Redpanda console container is started, connecting directly to <mark style="background-color:yellow;">redpanda:9092</mark>.
* Once the redpanda container [<mark style="color:blue;">is ready</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/redpanda\_operator/docker-compose.yml#L12C5-L12C27), docker compose starts an [<mark style="color:blue;">Ockam node in a container</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/redpanda\_operator/docker-compose.yml#L11-L19) as a companion to the redpanda container. The Ockam node container is created using [<mark style="color:blue;">this dockerfile</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/kafka/redpanda/docker/ockam.dockerfile) and this [<mark style="color:blue;">entrypoint script</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/redpanda\_operator/run\_ockam.sh). The enrollment ticket from run.sh is [<mark style="color:blue;">passed to the container</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/redpanda\_operator/docker-compose.yml#L17).
* When the Ockam node container starts in the Redpanda Operator network, it runs [<mark style="color:blue;">its entrypoint</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/redpanda\_operator/run\_ockam.sh)<mark style="color:blue;">.</mark> The entrypoint script creates a new identity and uses the enrollment ticket to [<mark style="color:blue;">enroll with your project</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/redpanda\_operator/run\_ockam.sh#L9) and setup kafka outlet
* The entrypoint script then [<mark style="color:blue;">creates a node that uses</mark> ](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/redpanda\_operator/run\_ockam.sh#L8-L21)this identity and membership credential to authenticate and create a <mark style="color:blue;">relay</mark> in the project, back to the node, at <mark style="background-color:yellow;">relay: redpanda</mark>. The run function [<mark style="color:blue;">gave the enrollment ticket permission</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/run.sh#L38C44-L38C60) to use this relay address.

#### Application Teams

```yaml
# Create a dedicated and isolated virtual network for application_team.
networks:
  application_team:
      driver: bridge
```

* Application Teams’s [<mark style="color:blue;">docker-compose configuration</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application\_team/docker-compose.yml) is used when run.sh invokes docker-compose. It creates an [<mark style="color:blue;">isolated virtual network</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application\_team/docker-compose.yml#L3-L5) for Application Teams. In this network, docker compose starts a Kafka consumer container and a Kafka producer container.
* The Kafka consumer node container is created using [<mark style="color:blue;">this dockerfile</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application\_team/kafka\_client.dockerfile) and this [<mark style="color:blue;">entrypoint script</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application\_team/run\_ockam.sh). The consumer enrollment ticket from run.sh is [<mark style="color:blue;">passed to the container</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application\_team/docker-compose.yml#L16) via environment variable.
* When the Kafka consumer node container starts in the Application Teams network, it runs [<mark style="color:blue;">its entrypoint</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application\_team/run\_ockam.sh)<mark style="color:blue;">.</mark> The entrypoint creates the Ockam node described by `ockam.yaml` described inside the file. The node will automatically create an identity, [<mark style="color:blue;">enroll with your project</mark>](https://github.com/build-trust/ockam/blob/develop/examples/command/portals/kafka/redpanda/docker/application\_team/run\_ockam.sh#L6-L15), and setup Kafka inlet.
* Next, the entrypoint at the end executes the command present in the docker-compose configuration, which launches a Kafka consumer waiting for messages in the <mark style="background-color:yellow;">demo</mark> topic. Once the messages are received, they are printed out.
* In the producer container the process is analogous, once the Ockam node is setup the command within docker-compose configuration launches a Kafka producer, sending 5 messages, each every 5 seconds.
* You can view the Redpanda console available at http://127.0.0.1:8080 to see the encrypted messages

### Recap

We sent end-to-end encrypted messages _through_ Redpanda.

Messages are encrypted with strong forward secrecy as soon as they leave a Producer. Redpanda only sees encrypted messages. The intended Consumer can decrypt messages. Other Consumers can only see encrypted messages.

All communication is mutually authenticated and authorized. Keys and credentials are automatically rotated. Access can be easily revoked.

### Cleanup

To delete all containers and images:

```sh
./run.sh cleanup
```
