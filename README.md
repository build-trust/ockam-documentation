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

# What is Ockam?

Ockam empowers you to build secure-by-design apps that can trust data-in-motion.

You can use Ockam to create end-to-end encrypted and mutually authenticated channels. Ockam secure channels authenticate using cryptographic identities and credentials. They give your apps granular control over all trust and access decisions. This control makes it easy to enforce fine-grained, attribute-based authorization policies – at scale.

These core capabilities are composed to enable private and secure communication in a wide variety of application architectures. For example, with one simple command, an app in your cloud can create an [<mark style="color:blue;">encrypted portal</mark>](./#portals) to a micro-service in another cloud. The service doesn’t need to be exposed to the Internet. You don’t have to change anything about networks or firewalls.

{% code fullWidth="false" %}
```sh
# Create a TCP Portal Inlet to a Postgres server that is running in
# a remote private VPC in another cloud.
ockam tcp-inlet create --from 15432 --to postgres

# Access the Postgres server on localhost.
psql --host localhost --port 15432
```
{% endcode %}

<figure><img src=".gitbook/assets/postgres (1).png" alt=""><figcaption></figcaption></figure>

Similarly, using another simple command a kafka producer can publish end-to-end encrypted messages for a specific kafka consumer. Kafka brokers in the middle can’t see, manipulate, or accidentally leak sensitive enterprise data. This minimizes risk to sensitive business data and makes it easy to comply with data governance policies.

## Encrypted Portals <a href="#portals" id="portals"></a>

Portals carry various application protocols over end-to-end encrypted Ockam secure channels.

For example: a TCP Portal carries TCP over Ockam, a Kafka Portal carries Kafka Protocol over Ockam, etc. Since portals work with existing application protocols you can use them through companion Ockam Nodes, that run adjacent to your application, without changing any of your application’s code.&#x20;

A tcp portal makes a remote tcp server **virtually adjacent** to the server’s clients. It has two parts: an inlet and an outlet. The outlet runs adjacent to the tcp server and inlets run adjacent to tcp clients. An inlet and the outlet work together to create a portal that makes the remote tcp server appear <mark style="background-color:yellow;">on localhost</mark> adjacent to a client. This client can then interact with this localhost server exactly like it would with the remote server. All communication between inlets and outlets is end-to-end encrypted.

<figure><img src=".gitbook/assets/Screenshot 2024-02-18 at 7.11.15 AM.png" alt=""><figcaption></figcaption></figure>

You can use Ockam Command to start nodes with one or more inlets or outlets. The underlying [<mark style="color:blue;">protocols</mark>](reference/protocols/) handle the hard parts — NATs are traversed; Keys are stored in vaults; Credentials are short-lived; Messages are authenticated; Data-integrity is guaranteed; Senders are protected from key compromise impersonation; Encryption keys are ratcheted; Nonces are never reused; Strong forward secrecy is ensured; Sessions recover from network failures; and a lot more.
