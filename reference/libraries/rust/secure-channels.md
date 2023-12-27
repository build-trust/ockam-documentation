---
description: >-
  Create end-to-end encrypted and mutually authenticated secure channels over
  any transport topology.
---

# Secure Channels

Now that we understand the basics of Nodes, Workers, and Routing ... let's create our first encrypted secure channel.

Establishing a secure channel requires establishing a shared secret key between the two entities that wish to communicate securely. This is usually achieved using a cryptographic key agreement protocol to safely derive a shared secret without transporting it over the network.

Running such protocols requires a stateful exchange of multiple messages and having a worker and routing system allows Ockam to hide the complexity of creating and maintaining a secure channel behind two simple functions:

* `create_secure_channel_listener(...)` which waits for requests to create a secure channel.
* `create_secure_channel(...)` which initiates the protocol to create a secure channel with a listener.

### Responder node

Create a new file at:

```
touch examples/05-secure-channel-over-two-transport-hops-responder.rs
```

Add the following code to this file:

```rust
// examples/05-secure-channel-over-two-transport-hops-responder.rs
// This node starts a tcp listener, a secure channel listener, and an echoer worker.
// It then runs forever waiting for messages.

use hello_ockam::Echoer;
use ockam::identity::SecureChannelListenerOptions;
use ockam::{node, Context, Result, TcpListenerOptions, TcpTransportExtension};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    // Create a node with default implementations
    let node = node(ctx).await?;

    // Initialize the TCP Transport.
    let tcp = node.create_tcp_transport().await?;

    node.start_worker("echoer", Echoer).await?;

    let bob = node.create_identity().await?;

    // Create a TCP listener and wait for incoming connections.
    let listener = tcp.listen("127.0.0.1:4000", TcpListenerOptions::new()).await?;

    // Create a secure channel listener for Bob that will wait for requests to
    // initiate an Authenticated Key Exchange.
    let secure_channel_listener = node
        .create_secure_channel_listener(
            &bob,
            "bob_listener",
            SecureChannelListenerOptions::new().as_consumer(listener.flow_control_id()),
        )
        .await?;

    // Allow access to the Echoer via Secure Channels
    node.flow_controls()
        .add_consumer("echoer", secure_channel_listener.flow_control_id());

    // Don't call node.stop() here so this node runs forever.
    Ok(())
}

```

### Middle node

Create a new file at:

```
touch examples/05-secure-channel-over-two-transport-hops-middle.rs
```

Add the following code to this file:

```rust
// examples/05-secure-channel-over-two-transport-hops-middle.rs
// This node creates a tcp connection to a node at 127.0.0.1:4000
// Starts a relay worker to forward messages to 127.0.0.1:4000
// Starts a tcp listener at 127.0.0.1:3000
// It then runs forever waiting to route messages.

use hello_ockam::Relay;
use ockam::{node, Context, Result, TcpConnectionOptions, TcpListenerOptions, TcpTransportExtension};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    // Create a node with default implementations
    let node = node(ctx).await?;

    // Initialize the TCP Transport
    let tcp = node.create_tcp_transport().await?;

    // Create a TCP connection to Bob.
    let connection_to_bob = tcp.connect("127.0.0.1:4000", TcpConnectionOptions::new()).await?;

    // Start a Relay to forward messages to Bob using the TCP connection.
    node.start_worker("forward_to_bob", Relay(connection_to_bob.into()))
        .await?;

    // Create a TCP listener and wait for incoming connections.
    let listener = tcp.listen("127.0.0.1:3000", TcpListenerOptions::new()).await?;

    node.flow_controls()
        .add_consumer("forward_to_bob", listener.flow_control_id());

    // Don't call node.stop() here so this node runs forever.
    Ok(())
}

```

### Initiator node

Create a new file at:

```
touch examples/05-secure-channel-over-two-transport-hops-initiator.rs
```

Add the following code to this file:

```rust
// examples/05-secure-channel-over-two-transport-hops-initiator.rs
// This node creates an end-to-end encrypted secure channel over two tcp transport hops.
// It then routes a message, to a worker on a different node, through this encrypted channel.

use ockam::identity::SecureChannelOptions;
use ockam::{node, route, Context, Result, TcpConnectionOptions, TcpTransportExtension};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    // Create a node with default implementations
    let mut node = node(ctx).await?;

    // Create an Identity to represent Alice.
    let alice = node.create_identity().await?;

    // Create a TCP connection to the middle node.
    let tcp = node.create_tcp_transport().await?;
    let connection_to_middle_node = tcp.connect("localhost:3000", TcpConnectionOptions::new()).await?;

    // Connect to a secure channel listener and perform a handshake.
    let r = route![connection_to_middle_node, "forward_to_bob", "bob_listener"];
    let channel = node
        .create_secure_channel(&alice, r, SecureChannelOptions::new())
        .await?;

    // Send a message to the echoer worker via the channel.
    // Wait to receive a reply and print it.
    let reply = node
        .send_and_receive::<String>(route![channel, "echoer"], "Hello Ockam!".to_string())
        .await?;
    println!("App Received: {}", reply); // should print "Hello Ockam!"

    // Stop all workers, stop the node, cleanup and return.
    node.stop().await
}

```

### Run

Run the responder in a separate terminal tab and keep it running:

```
cargo run --example 05-secure-channel-over-two-transport-hops-responder
```

Run the middle node in a separate terminal tab and keep it running:

```
cargo run --example 05-secure-channel-over-two-transport-hops-middle
```

Run the initiator:

```
cargo run --example 05-secure-channel-over-two-transport-hops-initiator
```

Note the message flow.
