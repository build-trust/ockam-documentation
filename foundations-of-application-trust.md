---
description: Zero [implicit] Trust - in infrastructure,
---

# Foundations of Application Trust

Applications must **build trust** in their infrastructure, their dependencies, and their data.

****

**Mutual authentication and end-to-end data integrity**

In order to trust information or instructions, that are received over the network, applications must **authenticate** all senders and **verify the integrity of data** **received** to assert what was received is exactly what was sent — free from errors or en-route tampering.

Application layer communication is also usually bi-directional since, at the very least, we have to acknowledge receipt of data to its senders. This means that authentication and the data integrity guarantee within applications must be **mutual** between any two communicating parts.

With Ockam, applications can, in a few lines of code, create mutually authenticated [secure channels](command-line/secure-channels.md) that guarantee end-to-end data integrity to senders and receivers of data.

#### **Zero trust in network boundaries,** third-party services, and infrastructure

Applications have moved out of enterprise data centers into multi-tenant cloud and edge environments. They operate in untrusted networks and increasingly rely on third-party managed services and infrastructure. This creates exponential growth in the **vulnerability surface of our application data**.

Data, within our applications, routinely flows over complex, multi-hop, multi-protocol routes — across network boundaries, beyond data centers, through queues and caches, via gateways and brokers — before reaching its end destination. The vulnerability surfaces of all these dependencies get added to the vulnerability surface of our application data and make it _unmanageable_.

Ockam end-to-end [secure channels](command-line/secure-channels.md) enable **application layer encryption** of all **data-in-motion**. The data integrity and confidentiality guarantee, of these channels, create a deny-by-default security posture that minimizes our vulnerability surface and gives our application true control over every data or service access decision. ****&#x20;

