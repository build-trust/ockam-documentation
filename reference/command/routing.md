---
description: >-
  Ockam Routing and Transports enable other Ockam protocols to provide
  end-to-end trust guarantees.
---

# Routing and Transports

Data, within modern applications, routinely flows over complex, multi-hop, multi-protocol routes — across network boundaries, beyond data centers, through queues and caches, via gateways and brokers — before reaching its end destination.

We wanted to enable [secure channels](secure-channels.md) that have end-to-end guarantees of data authenticity, integrity and confidentiality in any communication topology.

However, traditional secure communication protocol implementations are typically tightly coupled with transport protocols in a way that all their security is limited to the length and duration of the underlying transport connections

For example, most TLS[^1] implementations are coupled with TCP[^2] in a way that all the security guarantees of TLS are limited to the length and duration of the underlying TCP connection. If your application’s data and requests travel over two TCP connection hops `TCP -> TCP` then all TLS guarantees break at the bridge between the two networks. This bridge, gateway or load balancer then becomes a point of weakness for application data. To makes matters worse, if you don't setup another mutually authenticated TLS connection on the second hop between the gateway and your destination server then the entire second hop network – all applications and machines within it – become an attack vector to your application and its data.&#x20;

Traditional secure communication protocols are also unable to protect your application’s data if it travels over multiple different transport protocols. They can’t guarantee data authenticity or data integrity if your application’s communication path is `UDP -> TCP` or `BLE -> TCP`.

This is where Ockam Routing shines. It is a simple and lightweight message based protocol that makes it possible to bidirectionally exchange message over a large variety of communication topologies: `TCP -> TCP` or `TCP -> TCP -> TCP` or `BLE -> UDP -> TCP` or `BLE -> TCP -> TCP` or `TCP -> Kafka -> TCP` and more.

By layering Ockam [Secure Channels](secure-channels.md) and other protocols over Ockam Routing, we can provide end-to-end guarantees over arbitrary transport topologies.

## Routing

Let’s start by creating a node and sending a message to a worker on that node.

```
» ockam node create n1
...

» ockam message send hello --to /node/n1/service/echo
hello
```

We get a reply back and the message flow looked like this.

To achieve this, Ockam Routing Protocols messages carry with them two metadata fields: `onward_route` and `return_route`, where a route is a list of addresses.



<figure><img src="../../diagrams/plantuml/simple/simple.001.jpeg" alt=""><figcaption></figcaption></figure>

<figure><img src="../../diagrams/plantuml/one-hop/one-hop.001.jpeg" alt=""><figcaption></figcaption></figure>

```
» ockam message send hello --to /node/n1/service/hop/service/echo
hello
```

<figure><img src="../../diagrams/plantuml/two-hops/two-hops.001.jpeg" alt=""><figcaption></figcaption></figure>

```
» ockam message send hello --to /node/n1/service/hop/service/hop/service/echo
hello
```

<figure><img src="../../diagrams/plantuml/n-hops/n-hops.001.jpeg" alt=""><figcaption></figcaption></figure>

[^1]: Transport Layer Security

[^2]: Transmission Control Protocol
