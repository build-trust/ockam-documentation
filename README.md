---
description: Trust for Data-in-Motion
---

# What is Ockam?

Ockam is a suite of **open source** tools, programming libraries and cloud services to orchestrate end-to-end encryption, mutual authentication, key management, credential management & authorization policy enforcement — at scale.

Modern applications are distributed and have an unwieldy number of interconnections that must trustfully exchange data. Ockam helps build applications that are **secure and private by-design**&#x20;

#### Mutual authentication and end-to-end data integrity

In order to trust information or instructions, that are received over the network, applications must **authenticate** all senders and **verify the integrity of data** **received** to assert what was received is exactly what was sent — free from errors or en-route tampering.

Application layer communication is also usually bi-directional since, at the very least, we have to acknowledge receipt of data to its senders. This means that authentication and the data integrity guarantee within applications must be **mutual** between any two communicating parts.

#### **Zero trust in the network boundaries, infrastructure and intermediaries**

Applications have moved out of enterprise network boundaries into multi-tenant cloud environments, edge environments.&#x20;

Data, within applications, routinely flows over complex, multi-hop, multi-protocol routes — across network boundaries, beyond data centers, through queues and caches, via gateways and brokers — before reaching its end destination.

#### Least privileged, per-request access and privacy controls&#x20;

#### Managing keys, identities and credentials – safely, at scale





&#x20;











## Hello Ockam

Let's create a mutually authenticated and authorized secure channel, in three simple commands and then send an end-to-end encrypted message through this channel.

{% code overflow="wrap" %}
```bash
# Install Ockam Command using Homebrew
> brew install build-trust/ockam/ockam

# Create three Ockam nodes n1, n2 & n3
> for i in {1..3}; do ockam node create "n$i"; done

# Create a mutually authenticated, authorized, end-to-end encrypted secure channel
# from node n1, via node n2, over two tcp hops to api service on node n3.
#
# Then send an end-to-end encrypted message to the uppercase service on n3,
# using this channel.
# 
# n2 cannot see or tamper the onroute message
> ockam secure-channel create --from n1 --to /node/n1/node/n2/node/n3/service/api
    | ockam message send "hello ockam!" --from n1 --to -/service/uppercase
HELLO OCKAM
```
{% endcode %}

