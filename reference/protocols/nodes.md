---
description: >-
  Ockam Nodes and Workers decouple applications from the host environment and
  enable simple interfaces for stateful, asynchronous, and bi-directional
  message-based protocols.
---

# Nodes and Workers

At Ockam's core is a collection of cryptographic and messaging protocols. These protocols enable <mark style="color:orange;">private</mark> and <mark style="color:orange;">secure by design</mark> applications that provide end-to-end application layer trust in data.

Ockam is designed to make these protocols <mark style="color:orange;">easy</mark> and <mark style="color:orange;">safe</mark> to use in <mark style="color:orange;">any application environment</mark> – from highly scalable cloud services to tiny battery operated microcontroller based devices.

Many included protocols require multiple steps and have complicated internal state that must be managed with care. Protocol steps can often be initiated by any participant so it can be quite challenging to make these protocols simple to use, secure, and platform independent.

Ockam [<mark style="color:blue;">Nodes</mark>](nodes.md#node), [<mark style="color:blue;">Workers</mark>](nodes.md#worker), and [<mark style="color:blue;">Services</mark>](nodes.md#service) help hide this complexity to provide simple interfaces for stateful and asynchronous message-based protocols.

## Nodes

An Ockam Node is any program that can interact with other Ockam Nodes using various Ockam protocols like Ockam Routing and Ockam Secure Channels.

A typical Ockam Node is implemented as an asynchronous execution environment that can run very lightweight, concurrent, stateful actors called Ockam [<mark style="color:blue;">Workers</mark>](nodes.md#workers). Using Ockam [<mark style="color:blue;">Routing</mark>](broken-reference), a node can deliver messages from one worker to another local worker. Using Ockam Transports, nodes can also route messages to workers on other remote nodes.

In the following code snippet we create a node in Rust and then immediately stop it:

{% code lineNumbers="true" fullWidth="true" %}
```rust
// examples/01-node.rs
// This program creates and then immediately stops a node.

use ockam::{node, Context, Result};

/// Create and then immediately stop a node.
#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    let mut node = node(ctx);

    // Stop the node as soon as it starts.
    node.stop().await
}
```
{% endcode %}

A node requires an asynchronous runtime to concurrently execute workers. The default Ockam Node implementation in Rust uses `tokio`, a popular asynchronous runtime in the Rust ecosystem. There are also Ockam Node implementations that support various `no_std` embedded targets.

Nodes can be implemented in any language. The only requirement is that understand various Ockam protocols like Routing, Secure Channels, Identities etc.

## Workers <a href="#worker" id="worker"></a>

Ockam [<mark style="color:blue;">Nodes</mark>](nodes.md#nodes) run very lightweight, concurrent, and stateful actors called Ockam Workers. They are like processes on your operating system, except that they all live inside one node and are very lightweight so a node can have hundreds of thousands of them, depending on the capabilities of the machine hosting the node.

<img src="../../.gitbook/assets/file.excalidraw (7).svg" alt="" class="gitbook-drawing">

When a worker is started on a node, it is given one or more addresses. The node maintains a mailbox for each address and whenever a message arrives for a specific address it delivers that message to the corresponding worker. In response to a message, a worker can: make local decisions, change internal state, create more workers, or send more messages.

#### **Echoer worker**

To create a worker, we create a struct that can optionally have some fields to store the worker's internal state. If the worker is stateless, it can be defined as a field-less unit struct.

This struct:

* Must implement the `ockam::Worker` trait.
* Must have the `#[ockam::worker]` attribute on the Worker trait implementation.
* Must define two associated types `Context` and `Message`
  * The `Context` type is set to `ockam::Context.`
  * The `Message` type must be set to the type of messages the worker wishes to handle.

{% code lineNumbers="true" fullWidth="true" %}
```rust
// src/echoer.rs
use ockam::{Context, Result, Routed, Worker};

pub struct Echoer;

#[ockam::worker]
impl Worker for Echoer {
    type Context = Context;
    type Message = String;

    async fn handle_message(&mut self, ctx: &mut Context, msg: Routed<String>) -> Result<()> {
        println!("Address: {}, Received: {}", ctx.address(), msg);

        // Echo the message body back on its return_route.
        ctx.send(msg.return_route(), msg.body()).await
    }
}
```
{% endcode %}

#### App worker

When a new node starts and calls an `async` main function, it turns that function into a worker with address of `"app"`. This makes it easy to send and receive messages from the main function (i.e the `"app"` worker).

In the code below, we start a new `Echoer` worker at address `"echoer"`, send this `"echoer"` a message `"Hello Ockam!"` and then wait to receive a `String` reply back from the `"echoer"`.

{% code lineNumbers="true" fullWidth="true" %}
```rust
// examples/02-worker.rs
// This node creates a worker, sends it a message, and receives a reply.

use hello_ockam::Echoer;
use ockam::{node, Context, Result};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    let mut node = node(ctx);

    // Start a worker, of type Echoer, at address "echoer"
    node.start_worker("echoer", Echoer).await?;

    // Send a message to the worker at address "echoer".
    node.send("echoer", "Hello Ockam!".to_string()).await?;

    // Wait to receive a reply and print it.
    let reply = node.receive::<String>().await?;
    println!("App Received: {}", reply); // should print "Hello Ockam!"

    // Stop all workers, stop the node, cleanup and return.
    node.stop().await
}
```
{% endcode %}

{% hint style="info" %}
Run the above example:

```sh
cargo run --example 02-worker
```
{% endhint %}

#### Message Flow

The message flow looked like this:

<figure><img src="../../.gitbook/assets/spaces_B6iKP7pf6tEttefAJJtl_uploads_git-blob-11b9e2fb5dead6936895bce7fc88eaa86e30c3ef_simple.001 (2).jpeg" alt=""><figcaption></figcaption></figure>

Next, let’s explore how Ockam’s Application Layer Routing enables us to create protocols that provide end-to-end guarantees.

