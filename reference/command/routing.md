---
description: >-
  Ockam’s Application Layer Routing protocol makes it possible to create
  protocols that provide end-to-end security and privacy guarantees.
---

# Routing and Transports

Ockam's Application Layer Routing protocol allows us to send messages over any number of hops, within one node, or across many nodes. This enables us to layer other protocols that provide end-to-end security and privacy guarantees.

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
