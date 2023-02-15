# Secure Channels

```rust
// This node creates an end-to-end encrypted secure channel over two tcp transport hops.
// It then routes a message, to a worker on a different node, through this encrypted channel.

use ockam::identity::{Identity, TrustEveryonePolicy};
use ockam::{route, vault::Vault, Context, Result, TcpTransport, TCP};

#[ockam::node]
async fn main(mut ctx: Context) -> Result<()> {
    // Initialize the TCP Transport.
    TcpTransport::create(&ctx).await?;

    // Create a Vault to safely store secret keys for Alice.
    let vault = Vault::create();

    // Create an Identity to represent Alice.
    let alice = Identity::create(&ctx, &vault).await?;

    // Connect to a secure channel listener and perform a handshake.
    let r = route![(TCP, "localhost:3000"), "hop", (TCP, "localhost:4000"), "bob_listener"];
    let channel = alice.create_secure_channel(r, TrustEveryonePolicy).await?;

    // Send a message to the echoer worker via the channel.
    ctx.send(route![channel, "echoer"], "Hello Ockam!".to_string()).await?;

    // Wait to receive a reply and print it.
    let reply = ctx.receive::<String>().await?;
    println!("App Received: {}", reply); // should print "Hello Ockam!"

    // Stop all workers, stop the node, cleanup and return.
    ctx.stop().await
}
```

```rust
// This node creates a tcp connection to a node at 127.0.0.1:4000
// Starts a tcp listener at 127.0.0.1:3000
// It then runs forever waiting to route messages.

use hello_ockam::Hop;
use ockam::access_control::AllowAll;
use ockam::{Context, Result, TcpTransport};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    ctx.start_worker("hop", Hop, AllowAll, AllowAll).await?;

    // Initialize the TCP Transport.
    let tcp = TcpTransport::create(&ctx).await?;

    // Create a TCP listener and wait for incoming connections.
    tcp.listen("127.0.0.1:3000").await?;

    // Don't call ctx.stop() here so this node runs forever.
    Ok(())
}
```

```rust
// This node starts a tcp listener, a secure channel listener, and an echoer worker.
// It then runs forever waiting for messages.

use hello_ockam::Echoer;
use ockam::access_control::AllowAll;
use ockam::identity::{Identity, TrustEveryonePolicy};
use ockam::{vault::Vault, Context, Result, TcpTransport};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    ctx.start_worker("echoer", Echoer, AllowAll, AllowAll).await?;

    // Initialize the TCP Transport.
    let tcp = TcpTransport::create(&ctx).await?;

    // Create a TCP listener and wait for incoming connections.
    tcp.listen("127.0.0.1:4000").await?;

    // Create a Vault to safely store secret keys for Bob.
    let vault = Vault::create();

    // Create an Identity to represent Bob.
    let bob = Identity::create(&ctx, &vault).await?;

    // Create a secure channel listener for Bob that will wait for requests to
    // initiate an Authenticated Key Exchange.
    bob.create_secure_channel_listener("bob_listener", TrustEveryonePolicy)
        .await?;

    // Don't call ctx.stop() here so this node runs forever.
    Ok(())
}
```
