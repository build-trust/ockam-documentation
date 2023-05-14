---
description: >-
  Ockam Routing and Transports enable protocols that provide end-to-end
  guarantees to messages traveling across many network connection hops and
  protocols boundaries.
---

# Routing and Transports

Data, within modern applications, routinely flows over complex, multi-hop, multi-protocol routes before reaching its end destination. It’s common for application layer requests and data to move across network boundaries, beyond data centers, via shared or public networks, through queues and caches, from gateways and brokers to reach remote services and other distributed parts of an application.

<img src="../../.gitbook/assets/file.excalidraw (3) (2).svg" alt="" class="gitbook-drawing">

Ockam is designed to enable end-to-end application layer guarantees in any communication topology.

For example Ockam [<mark style="color:blue;">Secure Channels</mark>](secure-channels.md) provide end-to-end guarantees of data authenticity, integrity, and privacy in any of the above communication topologies. In contrast, traditional secure communication implementations are typically tightly coupled with transport protocols in a way that all their security is limited to the length and duration of one underlying transport connection.

For example, most TLS implementations are tightly coupled with the underlying TCP connection. If your application’s data and requests travel over two TCP connection hops `TCP -> TCP` then all TLS guarantees break at the bridge between the two networks. This bridge, gateway or load balancer then becomes a point of weakness for application data.

To make matters worse, if you don't setup another mutually authenticated TLS connection on the second hop between the gateway and your destination server then the entire second hop network – that may have thousands of applications and machines within it – becomes an attack vector to your application and its data. If any of these neighboring applications or machines are compromised then your application and its data can be easily compromised.

Traditional secure communication protocols are also unable to protect your application’s data if it travels over multiple different transport protocols. They can’t guarantee data authenticity or data integrity if your application’s communication path is `UDP -> TCP` or `BLE -> TCP`.

Ockam [<mark style="color:blue;">Routing</mark>](routing.md#routing) is a simple and lightweight message based protocol that makes it possible to bidirectionally exchange messages over a large variety of communication topologies: `TCP -> TCP` or `TCP -> TCP -> TCP` or `BLE -> UDP -> TCP` or `BLE -> TCP -> TCP` or `TCP -> Kafka -> TCP` or any other topology you can imagine.

Ockam [<mark style="color:blue;">Transports</mark>](routing.md) adapt Ockam Routing to various transport protocols. By layering Ockam [<mark style="color:blue;">Secure Channels</mark>](secure-channels.md) and other protocols over Ockam Routing, we can provide end-to-end guarantees over arbitrary transport topologies that span many networks and clouds.

## Routing

Let’s start by creating a [<mark style="color:blue;">node</mark>](nodes.md#nodes) and sending a message to a [<mark style="color:blue;">service</mark>](nodes.md#services) on that node.

```
» ockam reset -y
» ockam node create n1
» ockam message send 'Hello Ockam!' --to /node/n1/service/echo
Hello Ockam!
```

We get a reply back and the message flow looked like this.

<figure><img src="../../diagrams/plantuml/simple/simple.001.jpeg" alt=""><figcaption></figcaption></figure>

To achieve this, Ockam Routing Protocol messages carry, with them, two metadata fields: `onward_route` and `return_route`. A route is an ordered list of addresses describing the path that a message to travel. All of this information is carried in a really <mark style="color:orange;">compact binary</mark> format.

Pay very close attention to the Sender, Hop, and Replier rules in the below sequence diagrams. Note how `onward_route` and `return_route` are handled as the message travels.

<figure><img src="../../diagrams/plantuml/one-hop/one-hop.001.jpeg" alt=""><figcaption></figcaption></figure>

## Transports

Ockam Transports adapt Ockam [Routing](routing.md#routing) for specific transport protocol like TCP, UDP, WebSockets, Bluetooth etc. There is a growing base of Ockam Transport implementations in the [<mark style="color:blue;">Ockam Github Repository</mark>](https://github.com/build-trust/ockam).

Let’s start by exploring the TCP transport. Create two new nodes `n2` and `n3` and explicitly specify that they should listen on the local TCP addresses `127.0.0.1:7000` and `127.0.0.1:8000` respectively:

```
» ockam node create n2 --tcp-listener-address=127.0.0.1:7000
» ockam node create n3 --tcp-listener-address=127.0.0.1:8000
```

Next let's create two TCP connections, one from `n1 to n2` and the other from `n2 to n3`:

```
» ockam tcp-connection create --from n1 --to 127.0.0.1:7000
» ockam tcp-connection create --from n2 --to 127.0.0.1:8000
```

Next list the TCP connections on n1 and n2 to get their worker addresses:

```
» ockam tcp-connection list --node n1
+------+----------+-----------------+------------------------------------+------------------------------------+----------------------------------+
| Type | Mode     | Socket address  | Worker address                     | Processor address                  | Flow Control Id                  |
+------+----------+-----------------+------------------------------------+------------------------------------+----------------------------------+
| TCP  | Outgoing | 127.0.0.1:7000  | 0#ac40f7edbf7aca346b5d44acf82d43ba | 0#b5beb5aa7dd8142b169005bfadbee0ce | 8f84e5e01f315a66ddf8b647149afa3f |
+------+----------+-----------------+------------------------------------+------------------------------------+----------------------------------+
| TCP  | Incoming | 127.0.0.1:51824 | 0#dcdd313885e6be12ec737738d0d3af50 | 0#8bf2d0a72fae97009152dfdb29b89718 | ab38e85bd048703d9924e71785127f1c |
+------+----------+-----------------+------------------------------------+------------------------------------+----------------------------------+

» ockam tcp-connection list --node n2
+------+----------+-----------------+------------------------------------+------------------------------------+----------------------------------+
| Type | Mode     | Socket address  | Worker address                     | Processor address                  | Flow Control Id                  |
+------+----------+-----------------+------------------------------------+------------------------------------+----------------------------------+
| TCP  | Incoming | 127.0.0.1:51819 | 0#95dfbd2b4f237a24561abf2e32000ba0 | 0#840b31a7b03b7ae1516e0525bde66301 | a51fcb88605fd5c70202d8145dda55ae |
+------+----------+-----------------+------------------------------------+------------------------------------+----------------------------------+
| TCP  | Outgoing | 127.0.0.1:8000  | 0#7d2f9587d725311311668075598e291e | 0#4f335356057656680aff5d00675129c1 | 8114c61aa7e54dcac30b3c3854f3e555 |
+------+----------+-----------------+------------------------------------+------------------------------------+----------------------------------+
| TCP  | Incoming | 127.0.0.1:51826 | 0#ec898598701164aa5b981c01fe377ac8 | 0#09ae73dc57982fbdb43e04b76ad3e707 | 5b563b790b3048e5cfec7846c9061f3b |
+------+----------+-----------------+------------------------------------+------------------------------------+----------------------------------+

» ockam flow-control add-consumer --node n2 a51fcb88605fd5c70202d8145dda55ae /worker/7d2f9587d725311311668075598e291e producer
» ockam flow-control add-consumer --node n2 8114c61aa7e54dcac30b3c3854f3e555 /worker/95dfbd2b4f237a24561abf2e32000ba0 producer
```

Note, from the above output, that the TCP connection from `n1 to n2` on `n1` has worker address `ac40f7edbf7aca346b5d44acf82d43ba` and the TCP connection from `n2 to n3` on `n2` has the worker address `7d2f9587d725311311668075598e291e`. We can combine this information to send a message over two TCP hops.

```
» ockam message send hello --from n1 --to /worker/ac40f7edbf7aca346b5d44acf82d43ba/worker/7d2f9587d725311311668075598e291e/service/uppercase
HELLO
```

The message in the above command took the following route:

<img src="../../.gitbook/assets/file.excalidraw (3) (2).svg" alt="" class="gitbook-drawing">

In this example, we ran a simple `uppercase` request and response protocol between `n1` and `n3`, two nodes that weren't directly connected to each other. This simple combination of Ockam Routing and Transports the foundation of <mark style="color:orange;">end-to-end</mark> <mark style="color:orange;">protocols</mark> in Ockam.

We can have any number of TCP hops along the route to the uppercase service. We can also easily have some hops that use a completely different transport protocol like UDP or Bluetooth. Transport protocols are pluggable and there is a growing base of Ockam Transport Add-Ons in our [<mark style="color:blue;">Github Repository</mark>](https://github.com/build-trust/ockam).

#### Recap

{% hint style="info" %}
To cleanup and delete all nodes, run: `ockam node delete --all`
{% endhint %}

Ockam [<mark style="color:blue;">Routing</mark>](routing.md#routing) is a simple and lightweight message based protocol that makes it possible to bidirectionally exchange messages over a large variety of communication topologies: `TCP -> TCP` or `TCP -> TCP -> TCP` or `BLE -> UDP -> TCP` or `BLE -> TCP -> TCP` or `TCP -> Kafka -> TCP` or any other topology you can imagine. Ockam [<mark style="color:blue;">Transports</mark>](routing.md) adapt Ockam Routing to various transport protocols.

Together they give us a simple, yet extremely flexible, foundation to describe end-to-end, application layer protocols that can operate in any communication topology.

{% hint style="info" %}
If you’re stuck or have questions at any point, [<mark style="color:blue;">please reach out to us</mark>](https://www.ockam.io/contact)<mark style="color:blue;">**.**</mark>
{% endhint %}

Next, let's explore how Ockam [<mark style="color:blue;">Relays and Portals</mark>](advanced-routing.md) make it simple to connect existing applications across networks.
