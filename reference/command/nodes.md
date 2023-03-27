---
description: >-
  Ockam Nodes and Workers decouple applications from the host environment and
  enable simple interfaces to complex, stateful, and asynchronous message-based
  protocols.
---

# Nodes and Workers

At Ockam’s core are a collection of cryptographic and messaging protocols. These protocols make it possible to create <mark style="color:orange;">private</mark> and <mark style="color:orange;">secure by design</mark> applications that provide end-to-end application layer trust it data.

Our goal is to make these powerful protocols <mark style="color:orange;">easy</mark> and <mark style="color:orange;">safe</mark> to use in <mark style="color:orange;">any application environment</mark> – from highly scalable cloud services to tiny battery operated microcontroller based devices.

However, many of these protocols require multiple steps and have complicated internal state that must be managed with care. It can be quite challenging to make them simple to use, secure, and platform independent.

Ockam [Nodes](nodes.md#node), [Workers](nodes.md#worker), and [Services](nodes.md#service) help us decouple from the host environment and provide simple interfaces to our stateful and asynchronous message-based protocols.

## Node

An Ockam Node is any program that can interact with other Ockam Nodes using various Ockam Protocols like Ockam [Routing](routing.md) and Ockam [Secure Channels](secure-channels.md).

Ockam Nodes are designed to leverage the strengths of their operating environment. Our Rust implementation makes it easy to adapt to various architectures and processors. It can run efficiently on tiny microcontrollers or scale horizontally in cloud environments. You can create Ockam nodes using Ockam Command or embed one directly into your application using various Ockam [programming libraries](broken-reference).

Typically, an Ockam Node is implemented as an asynchronous execution environment that can run very lightweight, concurrent, stateful actors called Ockam [Workers](nodes.md#worker). Using Ockam Routing, a node can deliver messages from one worker to another local worker. Using Ockam Transports, nodes can also route messages to workers on other remote nodes.

Ockam Command makes is super easy to create and manage local or remote Ockam Nodes.

If you run `ockam node create`, it will create and start a node in the background and give it a random name:

```
» ockam node create

Node:
  Name: e1c233de
  Status: UP
...
```

You can also create a node with a name of your choice:

```
» ockam node create n1

Node:
  Name: n1
  Status: UP
...
```

The above nodes were started in the background, you can also start a node in the foreground and optionally tell it display verbose logs:

```
» ockam node create n2 --foreground --verbose
2023-01-26T15:23:53.624263Z  INFO ockam_node::node: Initializing ockam node
2023-01-26T15:23:53.626823Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#79758210d86b8efc7a2603dcd000efd3' with access control in:LocalSourceOnly out:LocalOnwardOnly
2023-01-26T15:23:53.627107Z  INFO ockam_node::processor_builder: Initializing ockam processor '0#3960258e7c4208499876c12c96b21314' with access control in:DenyAll out:DenyAll
2023-01-26T15:23:53.631477Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#echo' with access control in:AllowAll out:AllowAll
2023-01-26T15:23:53.631519Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#_internal.nodemanager' with access control in:AllowAll out:AllowAll
2023-01-26T15:23:53.631543Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#vault_service' with access control in:AllowAll out:AllowAll
2023-01-26T15:23:53.631587Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#ockam.ping.collector' with access control in:AllowAll out:DenyAll
2023-01-26T15:23:53.631692Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#identity_service' with access control in:AllowAll out:AllowAll
2023-01-26T15:23:53.631725Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#authenticated' with access control in:AllowAll out:AllowAll
2023-01-26T15:23:53.631749Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#uppercase' with access control in:AllowAll out:AllowAll
2023-01-26T15:23:53.631763Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#hop' with access control in:AllowAll out:AllowAll
2023-01-26T15:23:53.631786Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#forwarding_service' with access control in:AllowAll out:DenyAll
2023-01-26T15:23:53.631828Z  INFO ockam_api::nodes::service::secure_channel: Handling request to create a new secure channel listener: 0#api
2023-01-26T15:23:53.631932Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#api' with access control in:AllowAll out:DenyAll
2023-01-26T15:23:53.632008Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#credentials' with access control in:AllowAll out:AllowAll
...
```

You can see all running nodes with `ockam node list`

```
» ockam node list

Node:
  Name: e1c233de
  Status: UP
...

Node:
  Name: n1
  Status: UP
...

Node:
  Name: n2
  Status: UP
...
```

You can stop a running node with `ockam node stop`. This will stop the node but won't delete its state

```
» ockam node stop n1
```

You can start a stopped node with `ockam node start`.

```
» ockam node start n1

Node:
  Name: n1
  Status: UP
...
```

You can permanently delete a node by running:

```
» ockam node delete n1
Deleted node 'n1'
```

You can also delete all nodes with:

```
» ockam node delete --all
```

## Worker

Ockam [Nodes](nodes.md#node) run very lightweight, concurrent, and stateful actors called Ockam Workers.

When a worker is started on a node, it is given one or more addresses. The node maintains a mailbox for each address and whenever a message arrives for a specific address it delivers that message to the corresponding registered worker. In response to a message, an worker can: make local decisions, change its internal state, create more workers, or send more messages.

You can see the list of workers in a node by running:

```
» ockam worker list --at n1
Node: n1
  Workers:
    0bd13aa25990fcf84d69868ea62cb67e
    1305ca7d55d9694ff30f04906ff5396f
    222e361a13756be8eadac6dab91f99e4
    echo
    uppercase
    ...
```

Note the workers in node `n1` with address `echo` and `uppercase`. We’ll send them some messages below as we look at services. A node can also deliver messages to workers on a different node using the [Ockam Routing Protocol](routing.md) and its Transports. Later in this guide, when we [dig into routing](routing.md), we’ll send some messages across nodes.

From Ockam Command, we don’t usually create workers directly but instead start predefined [services](nodes.md#service) like Transports and Secure Channels that in turn start one or more workers. Using the Ockam [Rust Library](broken-reference) you can also build your own workers.

Because workers are stateful and can asynchronously send and receive messages they are a  potent abstraction that can take over the responsibility of running multi-step, stateful, and asynchronous message-based protocols. This makes it possible for Ockam Command and Ockam [Programming Libraries](broken-reference) to expose very simple and safe interfaces for powerful protocols.&#x20;

## Service

One or more Ockam Workers can work as a team to offer a Service. Services can also be attached to identities and authorization policies to enforce attribute based access control rules.

For example, nodes that are created with Ockam Command come with some predefined services including an example service `/service/uppercase` that responds with an uppercased version of whatever message you send it:

```
» ockam message send hello --to /node/n1/service/uppercase
HELLO
```

Services have addresses represented by `/service/{ADDRESS}`.

You can see a list of all services on a node by running:

```
» ockam service list --at n1
Node: n1
  Services:
    Service:
      Type: Uppercase
      Address: /service/uppercase
    Service:
      Type: Echoer
      Address: /service/echo
    Service:
      Type: Hop
      Address: /service/hop
    Service:
      Type: SecureChannelListener
      Address: /service/api
    ...
```

Later in this guide, we’ll explore other commands that interact with other pre-defined services like `/service/api` – every node created with Ockam Command starts a secure channel listener at this address to allow other nodes to create mutually authenticated channels with it.

Next, let’s explore how Ockam’s [Application Layer Routing](routing.md) protocol enables us to create protocols that provide end-to-end security and privacy guarantees.
