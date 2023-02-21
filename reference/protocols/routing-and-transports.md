---
description: >-
  Ockam Routing and Transports enable other Ockam protocols to provide
  end-to-end guarantees like trust, security, privacy, reliable delivery,
  ordering etc.
---

# Routing and Transports

Data, within modern applications, routinely flows over complex, multi-hop, multi-protocol routes before reaching its end destination. It’s common for application layer requests and data to move across network boundaries, beyond data centers, via shared or public networks, through queues and caches, from gateways and brokers to reach remote services and other distributed parts of an application.

Our goal is to enable end-to-end application layer guarantees in any communication topology. For example Ockam [Secure Channels](../command/secure-channels.md) can provide end-to-end guarantees of data authenticity, integrity, and confidentiality in any of the above communication topologies.

In contrast, traditional secure communication protocol implementations are typically tightly coupled with transport protocols in a way that all their security is limited to the length and duration of the underlying transport connections.

For example, most TLS[^1] implementations are coupled the underlying TCP connection. If your application’s data and requests travel over two TCP connection hops `TCP -> TCP` then all TLS guarantees break at the bridge between the two networks. This bridge, gateway or load balancer then becomes a point of weakness for application data. To makes matters worse, if you don't setup another mutually authenticated TLS connection on the second hop between the gateway and your destination server then the entire second hop network – all applications and machines within it – become attack vectors to your application and its data.&#x20;

Traditional secure communication protocols are also unable to protect your application’s data if it travels over multiple different transport protocols. They can’t guarantee data authenticity or data integrity if your application’s communication path is `UDP -> TCP` or `BLE -> TCP`.

Ockam [Routing](routing-and-transports.md#routing) is a simple and lightweight message based protocol that makes it possible to bidirectionally exchange message over a large variety of communication topologies: `TCP -> TCP` or `TCP -> TCP -> TCP` or `BLE -> UDP -> TCP` or `BLE -> TCP -> TCP` or `TCP -> Kafka -> TCP` and more. By layering Ockam [Secure Channels](../command/secure-channels.md) and other protocols over Ockam Routing, we can provide end-to-end guarantees over arbitrary transport topologies.

<figure><img src="../../diagrams/plantuml/simple/simple.001.jpeg" alt=""><figcaption></figcaption></figure>

<figure><img src="../../diagrams/plantuml/one-hop/one-hop.001.jpeg" alt=""><figcaption></figcaption></figure>

<figure><img src="../../diagrams/plantuml/two-hops/two-hops.001.jpeg" alt=""><figcaption></figcaption></figure>

<figure><img src="../../diagrams/plantuml/n-hops/n-hops.001.jpeg" alt=""><figcaption></figcaption></figure>

[^1]: Transport Layer Security
