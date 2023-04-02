---
description: >-
  Ockam Routing and Transports enable other Ockam protocols to provide
  end-to-end guarantees to messages that are traveling across many network
  connection hops and protocols boundaries.
---

# Routing and Transports

Data, within modern applications, routinely flows over complex, multi-hop, multi-protocol routes before reaching its end destination. It’s common for application layer requests and data to move across network boundaries, beyond data centers, via shared or public networks, through queues and caches, from gateways and brokers to reach remote services and other distributed parts of an application.

Our goal is to enable end-to-end application layer guarantees in any communication topology. For example Ockam [Secure Channels](secure-channels.md) can provide end-to-end guarantees of data authenticity, integrity, and confidentiality in any of the above communication topologies.

In contrast, traditional secure communication protocol implementations are typically tightly coupled with transport protocols in a way that all their security is limited to the length and duration of the underlying transport connections.

For example, most TLS[^1] implementations are coupled the underlying TCP connection. If your application’s data and requests travel over two TCP connection hops `TCP -> TCP` then all TLS guarantees break at the bridge between the two networks. This bridge, gateway or load balancer then becomes a point of weakness for application data. To makes matters worse, if you don't setup another mutually authenticated TLS connection on the second hop between the gateway and your destination server then the entire second hop network – all applications and machines within it – become attack vectors to your application and its data.&#x20;

Traditional secure communication protocols are also unable to protect your application’s data if it travels over multiple different transport protocols. They can’t guarantee data authenticity or data integrity if your application’s communication path is `UDP -> TCP` or `BLE -> TCP`.

Ockam [Routing](routing.md#routing) is a simple and lightweight message based protocol that makes it possible to bidirectionally exchange messages over a large variety of communication topologies: `TCP -> TCP` or `TCP -> TCP -> TCP` or `BLE -> UDP -> TCP` or `BLE -> TCP -> TCP` or `TCP -> Kafka -> TCP` and more. Ockam [Transports](routing.md) adapt Ockam Routing to various transport protocols.

By layering Ockam [Secure Channels](secure-channels.md) and other protocols over Ockam Routing, we can provide end-to-end guarantees over arbitrary transport topologies.

## Routing

Let’s start by creating a [node](nodes.md#node) and sending a message to a [service](nodes.md#service) on that node.

```
» ockam node create n1
...

» ockam message send 'Hello Ockam!' --to /node/n1/service/echo
Hello Ockam!
```

We get a reply back and the message flow looked like this.

<figure><img src="../../.gitbook/assets/simple.001 (1).jpeg" alt=""><figcaption></figcaption></figure>

To achieve this, Ockam Routing Protocols messages carry, with them, two metadata fields: `onward_route` and `return_route`.

<figure><img src="../../.gitbook/assets/one-hop.001.jpeg" alt=""><figcaption></figcaption></figure>

```
» ockam message send hello --to /node/n1/service/hop/service/echo
hello
```

<figure><img src="../../.gitbook/assets/two-hops.001.jpeg" alt=""><figcaption></figcaption></figure>

```
» ockam message send 'Hello Ockam!' --to /node/n1/service/hop/service/hop/service/echo
Hello Ockam!
```

<figure><img src="../../.gitbook/assets/n-hops.001.jpeg" alt=""><figcaption></figcaption></figure>

So far, we’ve routed messages within one Node.  Next let's see how we can route messages across nodes using Ockam Transports.

## Transports

Ockam Transports make Ockam Routing work over any transport protocol - TCP, UDP, BLE etc.

To see this in action, let’s create two new nodes `n2` and `n3`  and explicitly specify that they should listen on the local TCP addresses `127.0.0.1:7000` and `127.0.0.1:8000` respectively

```
» ockam node create n2 --tcp-listener-address=127.0.0.1:7000
...
» ockam node create n3 --tcp-listener-address=127.0.0.1:8000
...
```

Next let's create two TCP connections from `n1 to n2` and `n2 to n3`:

```
» ockam tcp-connection create --from n1 --to 127.0.0.1:7000
...
» ockam tcp-connection create --from n2 --to 127.0.0.1:8000
...
```

Next list the TCP connections on n1 and n2 to get their worker addresses:

```
» ockam tcp-connection list --node n1
+----------------------------------+----------------+-------------------+----------------+------------------------------------+
| Transport ID                     | Transport Type | Mode              | Socket address | Worker address                     |
+----------------------------------+----------------+-------------------+----------------+------------------------------------+
| 012dd419f165b7db47f4556948c76d42 | TCP            | Remote connection | 127.0.0.1:7000 | 0#f3a2e2814b0ae3ca446aa43aba2ee33d |
+----------------------------------+----------------+-------------------+----------------+------------------------------------+

» ockam tcp-connection list --node n2
+----------------------------------+----------------+-------------------+----------------+------------------------------------+
| Transport ID                     | Transport Type | Mode              | Socket address | Worker address                     |
+----------------------------------+----------------+-------------------+----------------+------------------------------------+
| c1cf9616e6c89cae6a098a7177b58a2e | TCP            | Remote connection | 127.0.0.1:8000 | 0#6af0e5768b510d14835154bd10060ed0 |
+----------------------------------+----------------+-------------------+----------------+------------------------------------+
```

Note that the TCP connection from `n1 to n2` has the worker address `f3a2e2814b0ae3ca446aa43aba2ee33d` on `n1` and the TCP connection from `n2 to n3` has the worker address `6af0e5768b510d14835154bd10060ed0` on `n2`. We can combine this information to send a message over two TCP hops.

```
» ockam message send hello --from n1 --to /worker/f3a2e2814b0ae3ca446aa43aba2ee33d/worker/6af0e5768b510d14835154bd10060ed0/service/uppercase
HELLO
```

<img src="../../.gitbook/assets/file.excalidraw.svg" alt="" class="gitbook-drawing">

[^1]: Transport Layer Security
