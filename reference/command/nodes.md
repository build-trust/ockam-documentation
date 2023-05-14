---
description: >-
  Ockam Nodes and Workers decouple applications from the host environment and
  enable simple interfaces for stateful and asynchronous message-based
  protocols.
---

# Nodes and Workers

At Ockam's core are a collection of cryptographic and messaging protocols. These protocols make it possible to create <mark style="color:orange;">private</mark> and <mark style="color:orange;">secure by design</mark> applications that provide end-to-end application layer trust it data.

Ockam is designed to make these powerful protocols <mark style="color:orange;">easy</mark> and <mark style="color:orange;">safe</mark> to use in <mark style="color:orange;">any application environment</mark> – from highly scalable cloud services to tiny battery operated microcontroller based devices.

However, many of these protocols require multiple steps and have complicated internal state that must be managed with care. It can be quite challenging to make them simple to use, secure, and platform independent.

<img src="../../.gitbook/assets/file.excalidraw (6).svg" alt="" class="gitbook-drawing">

Ockam [<mark style="color:blue;">Nodes</mark>](nodes.md#node), [<mark style="color:blue;">Workers</mark>](nodes.md#worker), and [<mark style="color:blue;">Services</mark>](nodes.md#service) help hide this complexity and decouple from the host environment - to provide simple interfaces for stateful and asynchronous message-based protocols.

## Nodes

An Ockam Node is any program that can interact with other Ockam Nodes using various Ockam protocols like Ockam [<mark style="color:blue;">Routing</mark>](routing.md) and Ockam [<mark style="color:blue;">Secure Channels</mark>](secure-channels.md).

You can create a standalone node using Ockam [<mark style="color:blue;">Command</mark>](./) or embed one directly into your application using various Ockam [<mark style="color:blue;">programming libraries</mark>](../libraries/). Nodes are built to leverage the strengths of their operating environment. Our [<mark style="color:blue;">Rust</mark>](../libraries/rust/) implementation, for example, makes it easy to adapt to various architectures and processors. It can run efficiently on tiny microcontrollers or scale horizontally in cloud environments.

A typical Ockam Node is implemented as an asynchronous execution environment that can run very lightweight, concurrent, stateful actors called Ockam [<mark style="color:blue;">Workers</mark>](nodes.md#workers). Using Ockam [<mark style="color:blue;">Routing</mark>](routing.md#routing), a node can deliver messages from one worker to another local worker. Using Ockam [<mark style="color:blue;">Transports</mark>](routing.md#transports), nodes can also route messages to workers on other remote nodes.

Ockam Command makes is super easy to create and manage local or remote nodes. If you run `ockam node create`, it will create and start a node in the background and give it a random name:

```
» ockam node create

Node:
  Name: e1c233de
  Status: UP
...
```

Similarly, you can also create a node with a name of your choice:

```
» ockam node create n1

Node:
  Name: n1
  Status: UP
...
```

You could also start a node in the foreground and optionally tell it display verbose logs:

```
» ockam node create n2 --foreground --verbose
2023-05-18T09:54:24.281248Z  INFO ockam_node::node: Initializing ockam node
2023-05-18T09:54:24.298089Z  INFO ockam_command::node::util: node state initialized name=n2
2023-05-18T09:54:24.298906Z  INFO ockam_node::processor_builder: Initializing ockam processor '0#c20e2e4aeb9fbae2b5be1529c83af54d' with access control in:DenyAll out:DenyAll
2023-05-18T09:54:24.299627Z  INFO ockam_api::cli_state::nodes: setup config updated name=n2
2023-05-18T09:54:24.302206Z  INFO ockam_api::nodes::service: NodeManager::create: n2
2023-05-18T09:54:24.302218Z  INFO ockam_api::nodes::service: NodeManager::create: starting default services
2023-05-18T09:54:24.302286Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#_internal.nodemanager' with access control in:AllowAll out:AllowAll
2023-05-18T09:54:24.302719Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#ockam.ping.collector' with access control in:AllowAll out:DenyAll
2023-05-18T09:54:24.302728Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#identity_service' with access control in:AllowAll out:AllowAll
2023-05-18T09:54:24.303179Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#authenticated' with access control in:AllowAll out:AllowAll
2023-05-18T09:54:24.303364Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#uppercase' with access control in:AllowAll out:AllowAll
2023-05-18T09:54:24.303527Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#forwarding_service' with access control in:AllowAll out:DenyAll
2023-05-18T09:54:24.303851Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#api' with access control in:AllowAll out:DenyAll
2023-05-18T09:54:24.304009Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#echo' with access control in:AllowAll out:AllowAll
2023-05-18T09:54:24.304056Z  INFO ockam_node::worker_builder: Initializing ockam worker '0#rpc_proxy_service' with access control in:AllowAll out:AllowAll
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

## Workers

Ockam [<mark style="color:blue;">Nodes</mark>](nodes.md#nodes) run very lightweight, concurrent, and stateful actors called Ockam Workers. They are like processes on your operating system, except that they all live inside one node and are very lightweight so a node can have hundreds of thousands of them, depending on the capabilities of the machine hosting the node.

<img src="../../.gitbook/assets/file.excalidraw (1).svg" alt="" class="gitbook-drawing">

When a worker is started on a node, it is given one or more addresses. The node maintains a mailbox for each address and whenever a message arrives for a specific address it delivers that message to the corresponding worker. In response to a message, a worker can: make local decisions, change internal state, create more workers, or send more messages.

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

Note the workers in node `n1` with address `echo` and `uppercase`. We'll send them some messages below as we look at services. A node can also deliver messages to workers on a different node using the [<mark style="color:blue;">Ockam Routing Protocol</mark>](routing.md) and its Transports. Later in this guide, when we [<mark style="color:blue;">dig into routing</mark>](routing.md), we'll send some messages across nodes.

From `ockam` command, we don't usually create workers directly but instead start predefined [<mark style="color:blue;">services</mark>](nodes.md#service) like Transports and Secure Channels that in turn start one or more workers. Using our [libraries](../libraries/) you can also develop your own workers.

Workers are stateful and can asynchronously send and receive messages. This makes them a potent abstraction that can take over the responsibility of running multistep, stateful, and asynchronous message-based protocols. This enables `ockam` command and Ockam [<mark style="color:blue;">Programming Libraries</mark>](../libraries/) to expose very simple and safe interfaces for powerful protocols.

## Services

One or more Ockam [<mark style="color:blue;">Workers</mark>](nodes.md#workers) can work as a team to offer a Service. Services can also be attached to a trust context and authorization policies to enforce attribute based access control rules.

For example, nodes that are created with Ockam Command come with some predefined services including an example service `/service/uppercase` that responds with an uppercased version of whatever message you send it:

```
» ockam message send hello --to /node/n1/service/uppercase
HELLO
```

Services have addresses represented by `/service/{ADDRESS}`. You can see a list of all services on a node by running:

```
» ockam service list --node n1
Node: n1
  Services:
    Service:
      Type: Uppercase
      Address: /service/uppercase
    Service:
      Type: Echoer
      Address: /service/echo
    Service:
      Type: SecureChannelListener
      Address: /service/api
    ...
```

Later in this guide, we'll explore other commands that interact with pre-defined services. For example every node created with `ockam` command starts a secure channel listener at the address `/service/api`, which allows other nodes to create mutually authenticated secure channels with it.

## Spaces

Ockam Spaces are an infinitely scalable Ockam [<mark style="color:blue;">Nodes</mark>](nodes.md#nodes) in the cloud. Ockam Orchestrator can create, manage, and scale spaces for you. Like other nodes, Spaces offer services. For example, you can create projects within a space, invite teammates to it, or attach payment subscriptions.

When your run `ockam enroll` for the first time, we create a space for you to host your projects.

```
» ockam enroll
...

» ockam space list
+--------------------------------------+----------+-------------------+
| Id                                   | Name     | Users             |
+--------------------------------------+----------+-------------------+
| 877c7a4d-b1be-4f36-8da6-be045ab64b60 | f27d39e1 | alice@example.com |
+--------------------------------------+----------+-------------------+
```

## Projects

Ockam Projects are also infinitely scalable Ockam [<mark style="color:blue;">Nodes</mark>](nodes.md#nodes) in the cloud. Ockam Orchestrator can create, manage, and scale projects for you. Projects are created within a [<mark style="color:blue;">Space</mark>](nodes.md#spaces) and can inherit permissions and subscriptions from their parent space. There can be many projects within one space.

When your run `ockam enroll` for the first time, we create a default project for you, within your default space.

```
» ockam enroll
...

» ockam project list
+--------------------------------------+---------+-------+------------+
| Id                                   | Name    | Users | Space Name |
+--------------------------------------+---------+-------+------------+
| 91c57e59-ad52-4b4e-9c4a-dd03113da939 | default |       | f27d39e1   |
+--------------------------------------+---------+-------+------------+
```

Like other nodes, Projects offer services. For example, the default project has an `echo` service just like the local nodes we created above. We can send messages and get replies from it. The `echo` service replies with the same message we send it.

```
» ockam message send hello --to /project/default/service/echo
hello
```

#### Recap

{% hint style="info" %}
To clean up and delete all nodes, run: `ockam node delete --all`
{% endhint %}

Ockam [<mark style="color:blue;">Nodes</mark>](nodes.md#nodes) are programs that interact with other nodes using one or more Ockam protocols like Routing and Secure Channels. Nodes run very lightweight, concurrent, and stateful actors called [<mark style="color:blue;">Workers</mark>](nodes.md#workers). Nodes and Workers hide complexities of environment and state to enable simple interfaces for stateful, asynchronous, message-based protocols.

One or more [<mark style="color:blue;">Workers</mark>](nodes.md#workers) can work as a team to offer a [<mark style="color:blue;">Service</mark>](nodes.md#services)<mark style="color:blue;">.</mark> Services can be attached to trust contexts and authorization policies to enforce attribute based access control rules. Ockam Orchestrator can create and manage infinitely scalable nodes in the cloud called [<mark style="color:blue;">Spaces</mark>](nodes.md#services) and [<mark style="color:blue;">Projects</mark>](nodes.md#projects) that offer managed services that are designed for scale and reliability.

{% hint style="info" %}
If you're stuck or have questions at any point, [<mark style="color:blue;">please reach out to us</mark>](https://www.ockam.io/contact)<mark style="color:blue;">**.**</mark>
{% endhint %}

Next, let's learn about Ockam's [<mark style="color:blue;">Application Layer Routing</mark>](routing.md) and how it enables protocols that provide end-to-end guarantees to messages traveling across many network connection hops and protocols boundaries.
