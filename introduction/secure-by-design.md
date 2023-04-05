---
description: >-
  Secure By Design applications minimize their vulnerability surface and embrace
  the principle of least privilege. They shrink both the target and the blast
  radius.
---

# Build to be Secure by Design

Ockam’s end-to-end secure channels guarantee authenticity, integrity, and confidentiality of all data-in-motion at the application layer. This enables a deny-by-default security posture that <mark style="color:orange;">exponentially reduces the vulnerability surface</mark> of an application and gives it true control over every access decision.

## End-to-End Data Integrity and Authenticity <a href="#end-to-end" id="end-to-end"></a>

In order to trust information or instructions, that are received over the network, applications must <mark style="color:orange;">authenticate</mark> all senders and <mark style="color:orange;">verify the integrity of data received</mark> to assert what was received is exactly what was sent — free from errors or en-route tampering.

Application layer communication is also usually bi-directional since, at the very least, we have to acknowledge receipt of data to its senders. This means that authentication and the data integrity guarantee within applications must be <mark style="color:orange;">mutual</mark> between any two communicating parts.

With Ockam, applications can, in a few lines of code, create mutually authenticated secure channels that guarantee end-to-end data integrity to senders and receivers of data.

## Zero \[ Implicit ] Trust

Modern applications operate in untrusted networks and increasingly rely on third-party services and infrastructure. This creates exponential growth in their vulnerability surface.

Ockam gives you the tools to eliminate implicit trust in networks, services, and infrastructure. Applications get provable cryptographic identities to authenticate and authorize every access decision.

Applications have moved out of enterprise data centers into multi-tenant cloud and edge environments. They operate in untrusted networks and increasingly rely on third-party managed services and infrastructure. This creates exponential growth in the **vulnerability surface of our application data**.

Data, within our applications, routinely flows over complex, multi-hop, multi-protocol routes — across network boundaries, beyond data centers, through queues and caches, via gateways and brokers — before reaching its end destination. The vulnerability surfaces of all these dependencies get added to the vulnerability surface of our application data and make it _unmanageable_.

Ockam end-to-end secure channels enable **application layer encryption** of all **data-in-motion**. The data integrity and confidentiality guarantee, of these channels, create a deny-by-default security posture that minimizes our vulnerability surface and gives our application true control over every data or service access decision.&#x20;

## Shift Security Left

Software cannot be secured from the outside. Ockam provides powerful building blocks to shift security left and make it an integral part of application design and development.

Application layer trust guarantees along with tools to manage keys, credentials and authorization policies give you granular control on the security and privacy properties of your application.

##

