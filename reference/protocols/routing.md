---
description: >-
  Ockam Routing and Transports enable higher level protocols that provide
  end-to-end guarantees to messages traveling across many network connection
  hops and protocols boundaries.
---

# Routing and Transports

Ockam Routing is a simple and lightweight message-based protocol that makes it possible to bidirectionally exchange messages over a large variety of communication topologies.&#x20;

Ockam Transports adapt Ockam Routing to various transport protocols like TCP, UDP, WebSockets, Bluetooth etc.

By layering Ockam Secure Channels and other higher level protocols over Ockam Routing, it is possible to build systems that provide end-to-end guarantees over arbitrary transport topologies that span many networks, connections, gateways, queues, and clouds.

## Routing

Let's dive into how the routing protocol works. So far, in the section on Nodes and Workers, we've come across this simple message exchange:



<figure><img src="../../.gitbook/assets/spaces_B6iKP7pf6tEttefAJJtl_uploads_git-blob-11b9e2fb5dead6936895bce7fc88eaa86e30c3ef_simple.001 (1) (1).jpeg" alt=""><figcaption></figcaption></figure>

Ockam Routing Protocol messages carry with them two metadata fields: an `onward_route` and a `return_route`. A route is an ordered list of addresses describing the path a message should  travel. This information is carried with the message in compact binary form.

Pay close attention to the Sender, Hop, and Replier rules in the sequence diagrams below. Note how `onward_route` and `return_route` are handled as the message travels.

<figure><img src="../../.gitbook/assets/spaces_B6iKP7pf6tEttefAJJtl_uploads_git-blob-c4e3111cde80f2de87732ba816be7bfeef8dcf8b_one-hop.001 (1).jpeg" alt=""><figcaption></figcaption></figure>

The above was one message hop. We may extend this to two hops:

<figure><img src="../../.gitbook/assets/spaces_B6iKP7pf6tEttefAJJtl_uploads_git-blob-b9b3e886aa1c902ef2233555087e5dc2bbc67dd6_two-hops.001 (1).jpeg" alt=""><figcaption></figcaption></figure>

This very simple protocol extends to any number of hops:

<figure><img src="../../.gitbook/assets/spaces_B6iKP7pf6tEttefAJJtl_uploads_git-blob-1ee1507fd0288c583c645bb32588414316806d03_n-hops.001 (1).jpeg" alt=""><figcaption></figcaption></figure>

#### Routing over two hops

So far, we've created an `"echoer"` worker in our node, sent it a message, and received a reply. This worker was a simple one hop away from our `"app"` worker.

To achieve this, messages carry with them two metadata fields: `onward_route` and `return_route`, where a route is a list of addresses.

To get a sense of how that works, let's route a message over two hops.

#### Hop worker

For demonstration, we'll create a simple worker, called `Hop`, that takes every incoming message and forwards it to the next address in the `onward_route` of that message.

Just before forwarding the message, `Hop`'s handle message function will:

1. Print the message
2. Remove its own address (first address) from the `onward_route`, by calling `step()`
3. Insert its own address as the first address in the `return_route` by calling `prepend()`

{% code lineNumbers="true" fullWidth="true" %}
```rust
// src/hop.rs

use ockam::{Any, Context, Result, Routed, Worker};

pub struct Hop;

#[ockam::worker]
impl Worker for Hop {
    type Context = Context;
    type Message = Any;

    /// This handle function takes any incoming message and forwards
    /// it to the next hop in it's onward route
    async fn handle_message(&mut self, ctx: &mut Context, msg: Routed<Any>) -> Result<()> {
        println!("Address: {}, Received: {}", ctx.address(), msg);

        // Some type conversion
        let mut message = msg.into_local_message();
        let transport_message = message.transport_mut();

        // Remove my address from the onward_route
        transport_message.onward_route.step()?;

        // Insert my address at the beginning return_route
        transport_message.return_route.modify().prepend(ctx.address());

        // Send the message on its onward_route
        ctx.forward(message).await
    }
}
```
{% endcode %}

#### App worker

Next, let's create our main `"app"` worker.

In the code below we start an `Echoer` worker at address `"echoer"` and a `Hop` worker at address `"h1"`. Then, we send a message along the `h1 => echoer` route by passing `route!["h1", "echoer"]` to `send(..)`.

{% code lineNumbers="true" fullWidth="true" %}
```rust
// examples/03-routing.rs

use hello_ockam::{Echoer, Hop};
use ockam::{node, route, Context, Result};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    // Create a node with default implementations
    let mut node = node(ctx);

    // Start a worker, of type Echoer, at address "echoer"
    node.start_worker("echoer", Echoer).await?;

    // Start a worker, of type Hop, at address "h1"
    node.start_worker("h1", Hop).await?;

    // Send a message to the worker at address "echoer",
    // via the worker at address "h1"
    node.send(route!["h1", "echoer"], "Hello Ockam!".to_string()).await?;

    // Wait to receive a reply and print it.
    let reply = node.receive::<String>().await?;
    println!("App Received: {}", reply); // should print "Hello Ockam!"

    // Stop all workers, stop the node, cleanup and return.
    node.stop().await
}
```
{% endcode %}

To run this new node program:

```
cargo run --example 03-routing
```

#### Routing over many hops

Similarly, we can also route the message via many hop workers:

{% code lineNumbers="true" fullWidth="true" %}
```rust
// examples/03-routing-many-hops.rs
// This node routes a message through many hops.

use hello_ockam::{Echoer, Hop};
use ockam::{node, route, Context, Result};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    // Create a node with default implementations
    let mut node = node(ctx);

    // Start an Echoer worker at address "echoer"
    node.start_worker("echoer", Echoer).await?;

    // Start 3 hop workers at addresses "h1", "h2" and "h3".
    node.start_worker("h1", Hop).await?;
    node.start_worker("h2", Hop).await?;
    node.start_worker("h3", Hop).await?;

    // Send a message to the echoer worker via the "h1", "h2", and "h3" workers
    let r = route!["h1", "h2", "h3", "echoer"];
    node.send(r, "Hello Ockam!".to_string()).await?;

    // Wait to receive a reply and print it.
    let reply = node.receive::<String>().await?;
    println!("App Received: {}", reply); // should print "Hello Ockam!"

    // Stop all workers, stop the node, cleanup and return.
    node.stop().await
}
```
{% endcode %}

To run this new node program:

```
cargo run --example 03-routing-many-hops
```

## Transport

An Ockam Transport is a plugin for Ockam Routing. It moves Ockam Routing messages using a specific transport protocol like TCP, UDP, WebSockets, Bluetooth etc.

In previous examples, we routed messages locally within one node. Routing messages over transport layer connections looks very similar.

Let's try the TcpTransport, we'll need to create two nodes: a responder and an initiator.

#### Responder node

{% code lineNumbers="true" fullWidth="true" %}
```rust
// examples/04-routing-over-transport-responder.rs
// This node starts a tcp listener and an echoer worker.
// It then runs forever waiting for messages.

use hello_ockam::Echoer;
use ockam::{node, Context, Result, TcpListenerOptions, TcpTransportExtension};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    // Create a node with default implementations
    let node = node(ctx);

    // Initialize the TCP Transport
    let tcp = node.create_tcp_transport().await?;

    // Create an echoer worker
    node.start_worker("echoer", Echoer).await?;

    // Create a TCP listener and wait for incoming connections.
    let listener = tcp.listen("127.0.0.1:4000", TcpListenerOptions::new()).await?;

    // Allow access to the Echoer via TCP connections from the TCP listener
    node.flow_controls().add_consumer("echoer", listener.flow_control_id());

    // Don't call node.stop() here so this node runs forever.
    Ok(())
}
```
{% endcode %}

#### Initiator node

{% code lineNumbers="true" fullWidth="true" %}
```rust
// examples/04-routing-over-transport-initiator.rs
// This node routes a message, to a worker on a different node, over the tcp transport.

use ockam::{node, route, Context, Result, TcpConnectionOptions, TcpTransportExtension};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    // Create a node with default implementations
    let mut node = node(ctx);

    // Initialize the TCP Transport.
    let tcp = node.create_tcp_transport().await?;

    // Create a TCP connection to a different node.
    let connection_to_responder = tcp.connect("localhost:4000", TcpConnectionOptions::new()).await?;

    // Send a message to the "echoer" worker on a different node, over a tcp transport.
    // Wait to receive a reply and print it.
    let r = route![connection_to_responder, "echoer"];
    let reply = node.send_and_receive::<String>(r, "Hello Ockam!".to_string()).await?;

    println!("App Received: {}", reply); // should print "Hello Ockam!"

    // Stop all workers, stop the node, cleanup and return.
    node.stop().await
}
```
{% endcode %}

#### Run

Run the responder in a separate terminal tab and keep it running:

```
cargo run --example 04-routing-over-transport-responder
```

Run the initiator:

```
cargo run --example 04-routing-over-transport-initiator
```

## Bridge

A common real world topology is a transport bridge.

Node `n1` wishes to access a service on node `n3`, but it can't directly connect to `n3`. This can happen for many reasons, maybe because `n3` is in a separate `IP` subnet, or it could be that the communication from `n1 to n2` uses UDP while from `n2 to n3` uses TCP or other similar constraints. The topology makes `n2` a bridge or gateway between these two separate networks.

<img src="../../.gitbook/assets/file.excalidraw (8).svg" alt="" class="gitbook-drawing">

We can setup this topology with Ockam Routing as follows:

#### Responder node

{% code lineNumbers="true" fullWidth="true" %}
```rust
// examples/04-routing-over-transport-two-hops-responder.rs
// This node starts a tcp listener and an echoer worker.
// It then runs forever waiting for messages.

use hello_ockam::Echoer;
use ockam::{node, Context, Result, TcpListenerOptions, TcpTransportExtension};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    // Create a node with default implementations
    let node = node(ctx);

    // Initialize the TCP Transport
    let tcp = node.create_tcp_transport().await?;

    // Create an echoer worker
    node.start_worker("echoer", Echoer).await?;

    // Create a TCP listener and wait for incoming connections.
    let listener = tcp.listen("127.0.0.1:4000", TcpListenerOptions::new()).await?;

    // Allow access to the Echoer via TCP connections from the TCP listener
    node.flow_controls().add_consumer("echoer", listener.flow_control_id());

    // Don't call node.stop() here so this node runs forever.
    Ok(())
}
```
{% endcode %}

#### Middle node

Relay worker

We'll create a worker, called `Relay`, that takes every incoming message and forwards it to the predefined address.

{% code lineNumbers="true" fullWidth="true" %}
```rust
// src/relay.rs

use ockam::{Address, Any, Context, LocalMessage, Result, Routed, Worker};

pub struct Forwarder(pub Address);

#[ockam::worker]
impl Worker for Forwarder {
    type Context = Context;
    type Message = Any;

    async fn handle_message(&mut self, ctx: &mut Context, msg: Routed<Any>) -> Result<()> {
        println!("Address: {}, Received: {}", ctx.address(), msg);

        // Some type conversion
        let mut transport_message = msg.into_local_message().into_transport_message();

        transport_message
            .onward_route
            .modify()
            .pop_front() // Remove my address from the onward_route
            .prepend(self.0.clone()); // Prepend predefined address to the onward_route

        let prev_hop = transport_message.return_route.next()?.clone();

        // Wipe all local info (e.g. transport types)
        let message = LocalMessage::new(transport_message, vec![]);

        if let Some(info) = ctx.flow_controls().find_flow_control_with_producer_address(&self.0) {
            ctx.flow_controls()
                .add_consumer(prev_hop.clone(), info.flow_control_id());
        }

        if let Some(info) = ctx.flow_controls().find_flow_control_with_producer_address(&prev_hop) {
            ctx.flow_controls().add_consumer(self.0.clone(), info.flow_control_id());
        }

        // Send the message on its onward_route
        ctx.forward(message).await
    }
}
```
{% endcode %}

{% code lineNumbers="true" fullWidth="true" %}
```rust
// examples/04-routing-over-transport-two-hops-middle.rs
// This node creates a tcp connection to a node at 127.0.0.1:4000
// Starts a forwarder worker to forward messages to 127.0.0.1:4000
// Starts a tcp listener at 127.0.0.1:3000
// It then runs forever waiting to route messages.

use hello_ockam::Forwarder;
use ockam::{node, Context, Result, TcpConnectionOptions, TcpListenerOptions, TcpTransportExtension};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    // Create a node with default implementations
    let node = node(ctx);

    // Initialize the TCP Transport
    let tcp = node.create_tcp_transport().await?;

    // Create a TCP connection to the responder node.
    let connection_to_responder = tcp.connect("127.0.0.1:4000", TcpConnectionOptions::new()).await?;

    // Create a Forwarder worker
    node.start_worker("forward_to_responder", Forwarder(connection_to_responder.into()))
        .await?;

    // Create a TCP listener and wait for incoming connections.
    let listener = tcp.listen("127.0.0.1:3000", TcpListenerOptions::new()).await?;

    // Allow access to the Forwarder via TCP connections from the TCP listener
    node.flow_controls()
        .add_consumer("forward_to_responder", listener.flow_control_id());

    // Don't call node.stop() here so this node runs forever.
    Ok(())
}
```
{% endcode %}

#### Initiator node

{% code lineNumbers="true" fullWidth="true" %}
```rust
// examples/04-routing-over-transport-two-hops-initiator.rs
// This node routes a message, to a worker on a different node, over two tcp transport hops.

use ockam::{node, route, Context, Result, TcpConnectionOptions, TcpTransportExtension};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    // Create a node with default implementations
    let mut node = node(ctx);

    // Initialize the TCP Transport
    let tcp = node.create_tcp_transport().await?;

    // Create a TCP connection to the middle node.
    let connection_to_middle_node = tcp.connect("localhost:3000", TcpConnectionOptions::new()).await?;

    // Send a message to the "echoer" worker, on a different node, over two tcp hops.
    // Wait to receive a reply and print it.
    let r = route![connection_to_middle_node, "forward_to_responder", "echoer"];
    let reply = node.send_and_receive::<String>(r, "Hello Ockam!".to_string()).await?;
    println!("App Received: {}", reply); // should print "Hello Ockam!"

    // Stop all workers, stop the node, cleanup and return.
    node.stop().await
}
```
{% endcode %}

#### Run

Run the responder in a separate terminal tab and keep it running:

```
cargo run --example 04-routing-over-transport-two-hops-responder
```

Run the middle node in a separate terminal tab and keep it running:

```
cargo run --example 04-routing-over-transport-two-hops-middle
```

Run the initiator:

```
cargo run --example 04-routing-over-transport-two-hops-initiator
```

## Relay

It is common, however, to encounter communication topologies where the machine that provides a service is unwilling or is not allowed to open a listening port or <mark style="color:orange;">expose</mark> a bridge node to other networks. This is a common security best practice in enterprise environments, home networks, OT networks, and VPCs across clouds. Application developers may not have control over these choices from the infrastructure / operations layer. This is where relays are useful.

<img src="../../.gitbook/assets/file.excalidraw (9).svg" alt="" class="gitbook-drawing">

Relays make it possible to establish end-to-end protocols with services operating in a remote private network, without requiring a remote service to expose listening ports to an outside hostile network like the Internet.

<img src="../../.gitbook/assets/file.excalidraw (10).svg" alt="" class="gitbook-drawing">

## Serialization

Ockam Routing messages when transported over the wire have the following structure. TransportMessage is serialized using [BARE Encoding](https://baremessages.org/). We intend to transition to CBOR in the near future since we already use CBOR for other protocols built on top of Ockam Routing.

{% code lineNumbers="true" fullWidth="true" %}
```rust
pub struct TransportMessage {
    pub version: u8,
    pub onward_route: Route,
    pub return_route: Route,
    pub payload: Vec<u8>,
}

pub struct Route {
    addresses: VecDeque<Address>
}

pub struct Address {
    transport_type: TransportType,
    transport_protocol_address: Vec<u8>,
}

pub struct TransportType(u8);
```
{% endcode %}

Each transport type has a conventional value. TCP has transport type 1. UDP has transport type 2 etc. Node local messages have transport type 0.

As message moves within a node it gathers additional metadata in structure like `LocalMessage` and `RelayMessage` that are used for a node's internal operation.

## Access Control

Each Worker has one or more addresses that it uses to send and receive messages. We assign each Address an <mark style="color:orange;">Incoming Access Control</mark> and an <mark style="color:orange;">Outgoing Access Control</mark>.

{% code lineNumbers="true" fullWidth="true" %}
```rust
#[async_trait]
pub trait IncomingAccessControl: Debug + Send + Sync + 'static {
    /// Return true if the message is allowed to pass, and false if not.
    async fn is_authorized(&self, relay_msg: &RelayMessage) -> Result<bool>;
}

#[async_trait]
pub trait OutgoingAccessControl: Debug + Send + Sync + 'static {
    /// Return true if the message is allowed to pass, and false if not.
    async fn is_authorized(&self, relay_msg: &RelayMessage) -> Result<bool>;
}
```
{% endcode %}

Concrete instances of these traits inspect a message's `onward_route`, `return_route`, metadata etc. along with other node local state to decide if a message should be allowed to be sent or received. Incoming Access Control filters which messages reach an address while Outgoing Access Control decides which messages can be sent.

## Flow Control

In our threat model, we assume that Workers within a Node are not malicious against each other. If programmed correctly they intend no harm.

However, there are certain types of Workers that forward messages that were created on other nodes. We don't implicitly trust other Ockam Nodes so messages from them can be dangerous. Such workers that can receive messages from another node are implemented with an Outgoing Access Control that denies all messages by default.

For example, a TCP Transport Listener spawns TCP Receivers for every new TCP connection. These receivers are implemented with an Outgoing Access Control that denies all messages, by default, from entering the node that is running the receiver. We can then explicitly allow messages to flow to a specific addresses.

In the [middle node](routing.md#middle-node) example above, we do this by explicitly allowing flow of messages from the TCP Receivers (spawned by TCP Transport Listener) to the `forward_to_responder` worker.

{% code lineNumbers="true" fullWidth="true" %}
```rust
// Create a TCP listener and wait for incoming connections.
let listener = tcp.listen("127.0.0.1:3000", TcpListenerOptions::new()).await?;

// Allow access to the Forwarder via TCP connections from the TCP listener
node.flow_controls()
    .add_consumer("forward_to_responder", listener.flow_control_id());
```
{% endcode %}

