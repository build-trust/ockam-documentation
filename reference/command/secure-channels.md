---
description: >-
  Ockam Secure Channels are mutually authenticated and end-to-end encrypted
  messaging channels that guarantee data authenticity, integrity, and
  confidentiality.
---

# Secure Channels

To [<mark style="color:blue;">trust data-in-motion</mark>](../../#trust-for-data-in-motion), applications need end-to-end guarantees of data authenticity, integrity, and confidentiality.

In previous sections, we saw how Ockam [<mark style="color:blue;">Routing</mark>](routing.md) and [<mark style="color:blue;">Transports</mark>](routing.md#transport)<mark style="color:blue;">,</mark> when combined with the ability to model [<mark style="color:blue;">Bridges</mark>](advanced-routing.md) and [<mark style="color:blue;">Relays</mark>](advanced-routing.md#relay), make it possible to <mark style="color:orange;">create end-to-end, application layer protocols in</mark> <mark style="color:orange;">**any**</mark> <mark style="color:orange;">communication topology</mark> - across networks, clouds, and protocols over many transport layer hops.

Ockam [Secure Channels](secure-channels.md#secure-channel) is an end-to-end protocol built on top of Ockam Routing. This cryptographic protocol guarantees data authenticity, integrity, and confidentiality over any communication topology that can be traversed with Ockam Routing.

<img src="../../.gitbook/assets/file.excalidraw (3) (1).svg" alt="" class="gitbook-drawing">

Distributed applications that are connected in this way can communicate without the risk of spoofing, tampering, or eavesdropping attacks, irrespective of transport protocols, communication topologies, and network configuration. As application data flows _across data centers, through queues and caches, via gateways and brokers -_ these intermediaries, like the relay in the above picture, can facilitate communication but cannot eavesdrop or tamper data.

In contrast, traditional secure communication implementations are typically tightly coupled with transport protocols in a way that all their security is limited to the length and duration of one underlying transport connection.

For example, most TLS implementations are tightly coupled with the underlying TCP connection. If your applications data and requests travel over two TCP connection hops `TCP -> TCP` then all TLS guarantees break at the bridge between the two networks. This bridge, gateway or load balancer then becomes a point of weakness for application data.

To make matters worse, if you don't set up another mutually authenticated TLS connection on the second hop between the gateway and your destination server, then the entire second hop network – which may have thousands of applications and machines within it – becomes an attack vector to your application and its data. If any of these neighboring applications or machines are compromised, then your application and its data can also be easily compromised.

Traditional secure communication protocols are also unable to protect your application's data if it travels over multiple different transport protocols. They can't guarantee data authenticity or data integrity if your application's communication path is `UDP -> TCP` or `BLE -> TCP`.

Ockam [<mark style="color:blue;">Routing</mark>](routing.md) and [<mark style="color:blue;">Transports</mark>](routing.md#transport)<mark style="color:blue;">,</mark> when combined with the ability to model [<mark style="color:blue;">Bridges</mark>](advanced-routing.md) and [<mark style="color:blue;">Relays</mark>](advanced-routing.md#relay) make it possible to bidirectionally exchange messages over a large variety of communication topologies: `TCP -> TCP` or `TCP -> TCP -> TCP` or `BLE -> UDP -> TCP` or `BLE -> TCP -> TCP` or `TCP -> Kafka -> TCP`, etc.

By layering Ockam Secure Channels over Ockam Routing, it becomes simple to provide end-to-end, application layer guarantees of data authenticity, integrity, and confidentiality in any communication topology.

## Secure Channels

Ockam Secure Channels provides the following <mark style="color:orange;">end-to-end guarantees</mark>:

1. **Authenticity:** Each end of the channel knows that messages received on the channel must have been sent by someone who possesses the secret keys of a specific Ockam [<mark style="color:blue;">Identifier</mark>](identities.md#identifiers).
2. **Integrity:** Each end of the channel knows that the messages received on the channel could not have been tapered en route and are exactly what was sent by the authenticated sender at the other end of the channel.
3. **Confidentiality:** Each end of the channel knows that the contents of messages received on the channel could not have been observed en route between the sender and the receiver.

<img src="../../.gitbook/assets/file.excalidraw (4).svg" alt="" class="gitbook-drawing">

To establish the secure channel, the two ends run an [<mark style="color:blue;">authenticated key establishment</mark>](../protocols/secure-channels.md) protocol and then [<mark style="color:blue;">authenticate</mark>](identities.md#identifier-authentication) each other's [<mark style="color:blue;">Ockam Identifier</mark>](identities.md#identifier) by signing the transcript hash of the key establishment protocol. The cryptographic key establishment safely derives shared secrets without transporting these secrets on the wire.

Once the shared secrets are established, they are used for authenticated encryption that ensures data integrity and confidentiality of application data.

Our secure channel protocol is based on a handshake design pattern described in the Noise Protocol Framework. Designs based on this framework are widely deployed and the described patterns have formal security proofs. The specific pattern that we use in Ockam Secure Channels provides sender and receiver authentication and is resistant to key compromise impersonation attacks. It also ensures the integrity and secrecy of application data and provides strong forward secrecy.

Now that you're familiar with the basics let's create some secure channels. If you haven't already, [<mark style="color:blue;">install ockam command</mark>](./#install)<mark style="color:blue;">,</mark> run `ockam enroll`, and [<mark style="color:blue;">delete any nodes</mark>](nodes.md#nodes) from previous examples.

## Hello Secure Channels <a href="#hello" id="hello"></a>

In this example, we'll create a secure channel from [Node](nodes.md) `a` to node `b`. Every node, created with Ockam Command, starts a secure channel listener at address `/service/api`.

```
» ockam node create a
» ockam node create b
» ockam secure-channel create --from a --to /node/b/service/api
     ✔︎ Secure Channel at /service/d92ef0aea946ec01cdbccc5b9d3f2e16 created successfully
       From /node/a to /node/b/service/api

» ockam message send hello --from a --to /service/d92ef0aea946ec01cdbccc5b9d3f2e16/service/uppercase
HELLO
```

In the above example, `a` and `b` mutually authenticate using the default [Ockam Identity](identities.md) that is generated when we create the first node. Both nodes, in this case, are using the same identity.

Once the channel is created, note above how we used the service address of the channel on `a` to send messages through the channel. This can be shortened to the one-liner:

```
» ockam secure-channel create --from a --to /node/b/service/api |
    ockam message send hello --from a --to -/service/uppercase
HELLO
```

The first command writes `/service/d92ef0aea946ec01cdbccc5b9d3f2e16`, the address of a new secure channel on `a`, to standard output and the second command replaces the `-` in the `to` argument with the value from standard input. Everything else works the same.

## Over Bridges <a href="#bridges" id="bridges"></a>

In a previous section, we learned that [Bridges](advanced-routing.md#bridges) enable end-to-end protocols between applications in separate networks in cases where we have a bridge node that is connected to both networks. Since Ockam Secure Channels are built on top of Ockam Routing, we can establish end-to-end secure channels over a route that may include one or more bridges.

<img src="../../.gitbook/assets/file.excalidraw (5).svg" alt="" class="gitbook-drawing">

[<mark style="color:blue;">Delete any existing nodes</mark>](nodes.md#nodes) and then try this example:

```
» ockam node create a
» ockam node create bridge1 --tcp-listener-address=127.0.0.1:7000
» ockam service start hop --at bridge1
» ockam node create bridge2 --tcp-listener-address=127.0.0.1:8000
» ockam service start hop --at bridge2
» ockam node create b --tcp-listener-address=127.0.0.1:9000

» ockam tcp-connection create --from a --to 127.0.0.1:7000
» ockam tcp-connection create --from bridge1 --to 127.0.0.1:8000
» ockam tcp-connection create --from bridge2 --to 127.0.0.1:9000

» ockam message send hello --from a --to /worker/ec8d523a2b9261c7fff5d0c66abc45c9/service/hop/worker/f0ea25511025c3a262b5dbd7b357f686/service/hop/worker/dd2306d6b98e7ca57ce660750bc84a53/service/uppercase
HELLO

» ockam secure-channel create --from a --to /worker/ec8d523a2b9261c7fff5d0c66abc45c9/service/hop/worker/f0ea25511025c3a262b5dbd7b357f686/service/hop/worker/dd2306d6b98e7ca57ce660750bc84a53/service/api \
    | ockam message send hello --from a --to -/service/uppercase
HELLO
```

## Through Relays <a href="#relays" id="relays"></a>

In a previous section, we also saw how [<mark style="color:blue;">Relays</mark>](advanced-routing.md#relay) make it possible to establish end-to-end protocols with services operating in a remote private network without requiring a remote service to expose listening ports on an outside hostile network like the Internet.

Since Ockam Secure Channels are built on top of Ockam Routing, we can establish end-to-end secure channels over a route that may include one or more relays.

<img src="../../.gitbook/assets/file.excalidraw (3) (1).svg" alt="" class="gitbook-drawing">

[<mark style="color:blue;">Delete any existing nodes</mark>](nodes.md#nodes) and then try this example:

```
» ockam node create relay --tcp-listener-address=127.0.0.1:7000

» ockam node create b
» ockam relay create b --at /node/relay --to b
    ✔︎ Now relaying messages from /node/relay/service/34df708509a28abf3b4c1616e0b37056 → /node/b/service/forward_to_b

» ockam node create a
» ockam tcp-connection create --from a --to 127.0.0.1:7000

» ockam secure-channel create --from a --to /worker/1fb75f2e7234035461b261602a714b72/service/forward_to_b/service/api \
    | ockam message send hello --from a --to -/service/uppercase
HELLO
```

## The Routing Sandwich

Ockam Secure Channels are built on top of Ockam Routing. But they also carry Ockam Routing messages.

<img src="../../.gitbook/assets/file.excalidraw (1) (2).svg" alt="" class="gitbook-drawing">

Any protocol that is implemented in this way melds with and becomes a seamless part of Ockam Routing. This means that we can run any Ockam Routing based protocol through Secure Channels. This also means that we can create <mark style="color:orange;">Secure Channels that pass through other Secure Channels.</mark>

The on-the-wire overhead of a new secure channel is only 20 bytes per message. This makes passing secure channels though other secure channels a powerful tool in many real world topologies.

## Elastic Encrypted Relays

Ockam Orchestrator can create and manage Elastic Encrypted [Relays](secure-channels.md#relays) in the cloud within your Orchestrator [project](nodes.md#project). These managed relays are designed for high availability, high throughput, and low latency.

Let's create an end-to-end secure channel through an elastic relay in your Orchestrator [project](nodes.md#project).

<img src="../../.gitbook/assets/file.excalidraw (3) (1).svg" alt="" class="gitbook-drawing">

The [<mark style="color:blue;">Project</mark>](nodes.md#project) that was created when you ran `ockam enroll` offers an Elastic Relay Service. [<mark style="color:blue;">Delete any existing nodes</mark>](nodes.md#nodes) and then try this new example:

```
» ockam project information --output json > project.json

» ockam node create a --project-path project.json
» ockam node create b --project-path project.json

» ockam relay create b --at /project/default --to /node/a
     ✔︎ Now relaying messages from /project/default/service/70c63af6590869c9bf9aa5cad45d1539 → /node/a/service/forward_to_b

» ockam secure-channel create --from a --to /project/default/service/forward_to_b/service/api \
    | ockam message send hello --from a --to -/service/uppercase
HELLO
```

Nodes `a` and `b` (the two ends) are mutually authenticated and are cryptographically guaranteed data authenticity, integrity, and confidentiality - even though their messages are traveling over the public Internet over two different TCP connections.

## Secure Portals

In a previous section, we saw how [<mark style="color:blue;">Portals</mark>](advanced-routing.md#portal) make existing application protocols work over Ockam Routing without changing any code in the existing applications.

We can combine Secure Channels with Portals to create Secure Portals.

<img src="../../.gitbook/assets/file.excalidraw (1) (1).svg" alt="" class="gitbook-drawing">

Continuing from the above example on [<mark style="color:blue;">Elastic Encrypted Relays</mark>](secure-channels.md#elastic-encrypted-relays) create a Python-based web server to represent a sample web service. This web service is listening on `127.0.0.1:9000`.

```
» python3 -m http.server --bind 127.0.0.1 9000

» ockam tcp-outlet create --at a --from /service/outlet --to 127.0.0.1:9000
» ockam secure-channel create --from a --to /project/default/service/forward_to_b/service/api \
    | ockam tcp-inlet create --at a --from 127.0.0.1:6000 --to -/service/outlet

» curl --head 127.0.0.1:6000
HTTP/1.0 200 OK
...
```

Then create a TCP Portal Outlet that makes `127.0.0.1:9000` available on worker address `/service/outlet` on `b`. We already have a forwarding relay for `b` on orchestrator `/project/default` at `/service/forward_to_b`.

We then create a TCP Portal Inlet on `a` that will listen for TCP connections to `127.0.0.1:6000`. For every new connection, the inlet creates a portal following the `--to` route all the way to the outlet. As it receives TCP data, it chunks and wraps them into Ockam Routing messages and sends them along the supplied route. The outlet receives Ockam Routing messages, unwraps them to extract TCP data, and send that data along to the target web service on `127.0.0.1:9000`. It all just seamlessly works.

The HTTP requests from curl, enter the inlet on `a`, travel to the orchestrator project node and are relayed back to `b` via it's forwarding relay to reach the outlet and onward to the Python-based web service. Responses take the same return route back to curl.

The TCP Inlet/Outlet work for a large number of TCP based protocols like HTTP. It is also simple to implement portals for other transport protocols. There is a growing base of Ockam Portal Add-Ons in our [<mark style="color:blue;">GitHub Repository</mark>](https://github.com/build-trust/ockam).

## Mutual Authorization

Trust and authorization decisions must be anchored in some pre-existing knowledge.

[<mark style="color:blue;">Delete any existing nodes</mark>](nodes.md#nodes) and then try this new example:

```
» ockam identity create i1
» ockam identity show i1 > i1.identifier
» ockam node create n1 --identity i1

» ockam identity create i2
» ockam identity show i2 > i2.identifier
» ockam node create n2 --identity i2

» ockam secure-channel-listener create l --at n2 \
    --identity i2 --authorized $(cat i1.identifier)

» ockam secure-channel create \
    --from n1 --to /node/n2/service/l \
    --identity i1 --authorized $(cat i2.identifier) \
      | ockam message send hello --from n1 --to -/service/uppercase
HELLO
```

#### Recap

{% hint style="info" %}
To clean up and delete all nodes, run: `ockam node delete --all`
{% endhint %}

Ockam [Secure Channels](secure-channels.md#secure-channel) is an end-to-end protocol built on top of Ockam Routing. This cryptographic protocol guarantees data authenticity, integrity, and confidentiality over any communication topology that can be traversed with Ockam Routing.

{% hint style="info" %}
If you're stuck or have questions at any point, [<mark style="color:blue;">please reach out to us</mark>](https://www.ockam.io/contact)<mark style="color:blue;">**.**</mark>
{% endhint %}

Next, let's explore how we can scale mutual authentication with Ockam [Credentials](credentials.md).
