---
description: >-
  Ockam Nodes and Workers decouple applications from the host environment and
  enable simple interfaces for stateful and asynchronous message-based
  protocols.
---

# Nodes and Workers

At Ockam’s core are a collection of cryptographic and messaging protocols. These protocols make it possible to create <mark style="color:orange;">private</mark> and <mark style="color:orange;">secure by design</mark> applications that provide end-to-end application layer trust it data.

Ockam is designed to make these powerful protocols <mark style="color:orange;">easy</mark> and <mark style="color:orange;">safe</mark> to use in <mark style="color:orange;">any application environment,</mark> from highly scalable cloud services to tiny battery operated microcontroller based devices.

However, many of these protocols require multiple steps and have complicated internal state that must be managed with care. It can be quite challenging to make them simple to use, secure, and platform independent.

Ockam [<mark style="color:blue;">Nodes and Workers</mark>](https://docs.ockam.io/reference/command/nodes) help hide this complexity and decouple from the host environment - to provide simple interfaces for stateful and asynchronous message-based protocols.

## Nodes

An Ockam Node is any program that can interact with other Ockam Nodes using various Ockam Protocols like Ockam [<mark style="color:blue;">Routing</mark>](routing.md) and Ockam Secure Channels.

Using the Ockam Rust crates, you can easily turn any application into a lightweight Ockam Node. This flexible approach allows your to build secure by design applications that can run efficiently on tiny microcontrollers or scale horizontally in cloud environments.

Rust based Ockam Nodes run very lightweight, concurrent, stateful actors called Ockam [<mark style="color:blue;">Workers</mark>](nodes.md#workers). Using Ockam Routing, a node can deliver messages from one worker to another local worker. Using Ockam Transports, nodes can also route messages to workers on other remote nodes.

A node requires an asynchronous runtime to concurrently execute workers. The default Ockam Node implementation in Rust uses `tokio`, a popular asynchronous runtime in the Rust ecosystem. We also support Ockam Node implementations for various `no_std` embedded targets.

#### Create a node

The first thing any Ockam rust program must do is initialize and start an Ockam node. This setup can be done manually but the most convenient way is to use the `#[ockam::node]` attribute that injects the initialization code. It creates the asynchronous environment, initializes worker management, sets up routing and initializes the node context.

For your new node, create a new file at `examples/01-node.rs` in your [<mark style="color:blue;">`hello_ockam`</mark>](./) project:

```
touch examples/01-node.rs
```

Add the following code to this file:

```rust
// examples/01-node.rs
// This program creates and then immediately stops a node.

use ockam::{node, Context, Result};
use r3bl_ansi_color::{AnsiStyledText, Color, Style};

#[rustfmt::skip]
const HELP_TEXT: &str =r#"
┌───────────────────────┐
│  Node 1               │
├───────────────────────┤
│  ┌─────────────────┐  │
│  │ Worker Address: │  │
│  │ 'app'           │  │
│  └─────────────────┘  │
└───────────────────────┘
"#;

/// Create and then immediately stop a node.
#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    AnsiStyledText {
        text: HELP_TEXT,
        style: &[Style::Foreground(Color::Rgb(100, 200, 0))],
    }
    .println();

    print_title(vec!["Run a node & stop it right away"]);

    // Create a node.
    let mut node = node(ctx).await?;

    // Stop the node as soon as it starts.
    node.stop().await
}

fn print_title(title: Vec<&str>) {
    let msg = format!("🚀 {}", title.join("\n  → "));
    AnsiStyledText {
        text: msg.as_str(),
        style: &[
            Style::Bold,
            Style::Foreground(Color::Rgb(70, 70, 70)),
            Style::Background(Color::Rgb(100, 200, 0)),
        ],
    }
    .println();
}

```

Here we add the `#[ockam::node]` attribute to an `async` main function that receives the node execution context as a parameter and returns `ockam::Result` which helps make our error reporting better.

As soon as the main function starts, we use `ctx.stop()` to immediately stop the node that was just started. If we don't add this line, the node will run forever.

To run the node program:

```
clear; OCKAM_LOG=none cargo run --example 01-node
```

{% hint style="info" %}
The `clear` command is used to clear the terminal before running the program. The `OCKAM_LOG=none` environment variable is used to disable logging. You can remove this to see the logs.
{% endhint %}

This will download various dependencies, compile and then run our code. When it runs, you'll see colorized output showing that the node starts up and then shuts down immediately 🎉.

## Workers

Ockam [<mark style="color:blue;">Nodes</mark>](nodes.md#node) run very lightweight, concurrent, and stateful actors called Ockam Workers.

When a worker is started on a node, it is given one or more addresses. The node maintains a mailbox for each address and whenever a message arrives for a specific address it delivers that message to the corresponding registered worker.

Workers can handle messages from other workers running on the same or a different node. In response to a message, an worker can: make local decisions, change its internal state, create more workers, or send more messages to other workers running on the same or a different node.

Above we've [<mark style="color:blue;">created our first node</mark>](nodes.md#create-a-node), now let's create a new worker, send it a message, and receive a reply.

#### **Echoer worker**

To create a worker, we create a struct that can optionally have some fields to store the worker's internal state. If the worker is stateless, it can be defined as a field-less unit struct.

This struct:

* Must implement the `ockam::Worker` trait.
* Must have the `#[ockam::worker]` attribute on the Worker trait implementation
* Must define two associated types `Context` and `Message`
  * The `Context` type is usually set to `ockam::Context` which is provided by the node implementation.
  * The `Message` type must be set to the type of message the worker wishes to handle.

For a new `Echoer` worker, create a new file at `src/echoer.rs` in your [<mark style="color:blue;">hello\_ockam</mark>](https://github.com/build-trust/ockam/blob/develop/documentation/guides/rust/#setup) project. We're creating this inside the `src` directory so we can easily reuse the `Echoer` in other examples that we'll write later in this guide:

```
touch src/echoer.rs
```

Add the following code to this file:

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

Note that we define the `Message` associated type of the worker as `String`, which specifies that this worker expects to handle `String` messages. We then go on to define a `handle_message(..)` function that will be called whenever a new message arrives for this worker.

In the Echoer's `handle_message(..)`, we print any incoming message, along with the address of the `Echoer`. We then take the body of the incoming message and echo it back on its return route (more about routes soon).

To make this Echoer type accessible to our main program, export it from `src/lib.rs` file by adding the following to it:

```rust
// src/lib.rs
mod echoer;

pub use echoer::*;

mod hop;
mod relay;

pub use hop::*;
pub use relay::*;

mod logger;
mod project;
mod token;

pub use logger::*;
pub use project::*;
pub use token::*;

```

#### App worker

When a new node starts and calls an `async` main function, it turns that function into a worker with address of `"app"`. This makes it easy to send and receive messages from the main function (i.e the `"app"` worker).

In the code below, we start a new `Echoer` worker at address `"echoer"`, send this `"echoer"` a message `"Hello Ockam!"` and then wait to receive a `String` reply back from the `"echoer"`.

Create a new file at:

```
touch examples/02-worker.rs
```

Add the following code to this file:

```rust
// examples/02-worker.rs
// This node creates a worker, sends it a message, and receives a reply.

use hello_ockam::Echoer;
use ockam::{node, Context, Result};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    // Create a node with default implementations
    let mut node = node(ctx).await?;

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

To run this new node program:

```
cargo run --example 02-worker
```

You'll see console output that shows `"Hello Ockam!"` received by the `"echoer"` and then an echo of it received by the `"app"`.

#### Message Flow

The message flow looked like this:

<figure><img src="../../../diagrams/plantuml/simple/simple.001.jpeg" alt=""><figcaption></figcaption></figure>

Next, let’s explore how Ockam’s [<mark style="color:blue;">Application Layer Routing</mark>](routing.md) enables us to create protocols that provide end-to-end security and privacy guarantees.
