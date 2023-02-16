---
description: >-
  Ockam’s Application Layer Routing protocol makes it possible to create other
  protocols that layer on top of routing to provide end-to-end guarantees.
---

# Routing and Transports

Data, within modern applications, routinely flows over complex, multi-hop, multi-protocol routes — across network boundaries, beyond data centers, through queues and caches, via gateways and brokers — before reaching its end destination.

Traditionally secure communication protocols are tightly coupled with transport protocols. For example most TLS[^1] implementations are coupled with TCP[^2] in a way that all the security guarantees of TLS are limited to the length and duration of the underlying TCP connection.

If your application’s data and requests travel over two TCP hops then all TLS guarantees break at the bridge between the two networks. This bridge, gateway or load balancer then becomes a point of weakness for application data. To makes matters worse, if you don't setup another mutually authenticated TLS connection on the second hop between the gateway and your destination server then the entire second hop network – all applications and machines within it – become an attack vector to your application and its data.&#x20;

Traditionally secure communication protocols are also unable to protect your application’s data and requests if they travel over multiple different transport protocols. They can’t protect your application’s instructions and data if the communication path is BLE -> UDP -> TCP.

We want to enable [secure channels](secure-channels.md) that have end-to-end guarantees of data authenticity, integrity and confidentiality in any communication topology. This is where Ockam’s [Routing](routing.md#routing) Protocol comes in. It is a lightweight, layer 7, routing protocol that can bidirectionally deliver messages over any number of hops, within one Ockam [Node](nodes.md), or across many nodes.

## Routing

```
» ockam message send hello --to /node/n1/service/echo
hello
```

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
