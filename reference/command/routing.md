---
description: >-
  Ockam Routing and Transports enable protocols that provide end-to-end
  guarantees to messages traveling across many network connection hops and
  protocols boundaries.
---

# Routing and Transports

Data, within modern applications, routinely flows over complex, multi-hop, multi-protocol routes before reaching its end destination. It's common for application layer requests and data to move across network boundaries, beyond data centers, via shared or public networks, through queues and caches, from gateways and brokers to reach remote services and other distributed parts of an application.

<img src="../../.gitbook/assets/file.excalidraw (3) (2).svg" alt="" class="gitbook-drawing">

Ockam is designed to enable end-to-end application layer guarantees in any communication topology.

For example, Ockam [<mark style="color:blue;">Secure Channels</mark>](secure-channels.md) provide end-to-end guarantees of data authenticity, integrity, and privacy in any of the above communication topologies. In contrast, traditional secure communication implementations are typically tightly coupled with transport protocols in a way that all their security is limited to the length and duration of one underlying transport connection.

For example, most TLS implementations are tightly coupled with the underlying TCP connection. If your application's data and requests travel over two TCP connection hops `TCP -> TCP`, then all TLS guarantees break at the bridge between the two networks. This bridge, gateway or load balancer then becomes a point of weakness for application data.

To make matters worse, if you don't set up another mutually authenticated TLS connection on the second hop between the gateway and your destination server, then the entire second hop network – which may have thousands of applications and machines within it – becomes an attack vector to your application and its data. If any of these neighboring applications or machines are compromised, then your application and its data can also be easily compromised.

Traditional secure communication protocols are also unable to protect your application's data if it travels over multiple different transport protocols. They can't guarantee data authenticity or data integrity if your application's communication path is `UDP -> TCP` or `BLE -> TCP`.

Ockam [<mark style="color:blue;">Routing</mark>](routing.md#routing) is a simple and lightweight message-based protocol that makes it possible to bidirectionally exchange messages over a large variety of communication topologies: `TCP -> TCP` or `TCP -> TCP -> TCP` or `BLE -> UDP -> TCP` or `BLE -> TCP -> TCP` or `TCP -> Kafka -> TCP` or any other topology you can imagine.

Ockam [<mark style="color:blue;">Transports</mark>](routing.md) adapt Ockam Routing to various transport protocols. By layering Ockam [<mark style="color:blue;">Secure Channels</mark>](secure-channels.md) and other protocols over Ockam Routing, we can provide end-to-end guarantees over arbitrary transport topologies that span many networks and clouds.

## Routing

Let's start by creating a [<mark style="color:blue;">node</mark>](nodes.md#nodes) and sending a message to a [<mark style="color:blue;">service</mark>](nodes.md#services) on that node.

```
» ockam reset -y
» ockam node create n1
» ockam message send 'Hello Ockam!' --to /node/n1/service/echo
Hello Ockam!
```

We get a reply back and the message flow looked like this.

<figure><img src="../../diagrams/plantuml/simple/simple.001.jpeg" alt=""><figcaption></figcaption></figure>

To achieve this, Ockam Routing Protocol messages carry, with them, two metadata fields: `onward_route` and `return_route`. A route is an ordered list of addresses describing a message's path travel. All of this information is carried in a really <mark style="color:orange;">compact binary</mark> format.

Pay very close attention to the Sender, Hop, and Replier rules in the sequence diagrams below. Note how `onward_route` and `return_route` are handled as the message travels.

<figure><img src="../../diagrams/plantuml/one-hop/one-hop.001.jpeg" alt=""><figcaption></figcaption></figure>

The above was just one message hop. We can extend this to two hops:

```
» ockam service start hop h1
» ockam message send hello --to /node/n1/service/h1/service/echo
hello
```

<figure><img src="../../diagrams/plantuml/two-hops/two-hops.001.jpeg" alt=""><figcaption></figcaption></figure>

This very simple protocol can extend to any number of hops, try following command:

```
» ockam service start hop h2
» ockam message send hello --to /node/n1/service/h1/service/h2/service/echo
hello
```

<figure><img src="../../diagrams/plantuml/n-hops/n-hops.001.jpeg" alt=""><figcaption></figcaption></figure>

So far, we've routed messages between Workers on one Node. Next, let's see how we can route messages across nodes and machines using Ockam Routing adapters called Transports.

## Transports

Ockam Transports adapt Ockam [Routing](routing.md#routing) for specific transport protocol, like TCP, UDP, WebSockets, Bluetooth etc. There is a growing base of Ockam Transport implementations in the [<mark style="color:blue;">Ockam GitHub Repository</mark>](https://github.com/build-trust/ockam).

Let's start by exploring TCP transport. Create two new nodes: `n2` and `n3` and explicitly specify that they should listen on the local TCP addresses `127.0.0.1:7000` and `127.0.0.1:8000` respectively:

```
» ockam node create n2 --tcp-listener-address=127.0.0.1:7000
» ockam node create n3 --tcp-listener-address=127.0.0.1:8000
```

Next, let's create two TCP connections, one from `n1 to n2` and the other from `n2 to n3`. Let's also add a hop for routing purposes:

```
» ockam service start --at n2 hop
» ockam tcp-connection create --from n1 --to 127.0.0.1:7000
» ockam tcp-connection create --from n2 --to 127.0.0.1:8000
```

Note, from the output, that the TCP connection from `n1 to n2` on `n1` has worker address `ac40f7edbf7aca346b5d44acf82d43ba` and the TCP connection from `n2 to n3` on `n2` has the worker address `7d2f9587d725311311668075598e291e`. We can combine this information to send a message over two TCP hops.

```
» ockam message send hello --from n1 --to /worker/ac40f7edbf7aca346b5d44acf82d43ba/service/hop/worker/7d2f9587d725311311668075598e291e/service/uppercase
HELLO
```

The message in the above command took the following route:

<img src="../../.gitbook/assets/file.excalidraw (3) (2).svg" alt="" class="gitbook-drawing">

In this example, we ran a simple `uppercase` request and response protocol between `n1` and `n3`, two nodes that weren't directly connected to each other. This simple combination of Ockam Routing and Transports the foundation of <mark style="color:orange;">end-to-end</mark> <mark style="color:orange;">protocols</mark> in Ockam.

We can have any number of TCP hops along the route to the uppercase service. We can also easily have some hops that use a completely different transport protocol, like UDP or Bluetooth. Transport protocols are pluggable, and there is a growing base of Ockam Transport Add-Ons in our [<mark style="color:blue;">GitHub Repository</mark>](https://github.com/build-trust/ockam).

#### Recap

{% hint style="info" %}
To clean up and delete all nodes, run: `ockam node delete --all`
{% endhint %}

Ockam [<mark style="color:blue;">Routing</mark>](routing.md#routing) is a simple and lightweight message-based protocol that makes it possible to bidirectionally exchange messages over a large variety of communication topologies: `TCP -> TCP` or `TCP -> TCP -> TCP` or `BLE -> UDP -> TCP` or `BLE -> TCP -> TCP` or `TCP -> Kafka -> TCP` or any other topology you can imagine. Ockam [<mark style="color:blue;">Transports</mark>](routing.md) adapt Ockam Routing to various transport protocols.

Together they give us a simple yet extremely flexible foundation to describe end-to-end, application layer protocols that can operate in any communication topology.

{% hint style="info" %}
If you're stuck or have questions at any point, [<mark style="color:blue;">please reach out to us</mark>](https://www.ockam.io/contact)<mark style="color:blue;">**.**</mark>
{% endhint %}

Next, let's explore how Ockam [<mark style="color:blue;">Relays and Portals</mark>](advanced-routing.md) make it simple to connect existing applications across networks.
