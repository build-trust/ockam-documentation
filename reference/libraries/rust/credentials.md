---
description: >-
  Scale mutual trust using lightweight, short-lived, revokable, attribute-based
  credentials.
---

# Credentials and Authorities

Ockam Secure Channels enable you to setup mutually authenticated and end-to-end encrypted communication. Once a channel is established, it has the following guarantees:

1. **Authenticity:** Each end of the channel knows that messages received on the channel must have been sent by someone who possesses the secret keys of specific Ockam Cryptographic Identifier.
2. **Integrity:** Each end of the channel knows that the messages received on the channel could not have been tapered en-route and are exactly what was sent by the authenticated sender at the other end of the channel.
3. **Confidentiality:**  Each end of the channel knows that the contents of messages received on the channel could not have been observed en-route between the sender and the receiver.

These guarantees however don't automatically imply trust. They don't tell us if a particular sender is trusted to inform us about a particular topic or if the sender is authorized to get a response to a particular request.

One way to create trust and authorize requests would be to use Access Control Lists (ACLs), where every receiver of messages would have a preconfigured list of identifiers that are trusted to inform about a certain topic or trigger certain requests. This approach works but doesn't scale very well. It becomes very cumbersome to manage mutual trust if you have more that a few nodes communicating with each other.

Another, and significantly more scalable, approach is to use Ockam <mark style="color:orange;">Credentials</mark> combined with <mark style="color:orange;">Attribute Based Access Control (ABAC)</mark>. In this setup every participant starts off by trusting a single Credential Issuer to be the authority on the attributes of an Identifier. This authority issues cryptographically signed credentials to attest to these attributes. Participants can then exchange and authenticate each others’ credentials to collect authenticated attributes about an identifier. Every participant uses these authenticated attributes to make authorization decisions based on attribute-based access control policies.

Let’s walk through an example of setting up ABAC using cryptographically verifiable credentials.

### Setup

To get started please create the initial [hello\_ockam project](./#get-started) and define and [echoer worker](nodes.md#echoer-worker). We'll also need the `hex` crate for this example so add that to your `Cargo.toml` using `cargo add` :

```
cargo add hex
```

### Credential Issuer

Any Ockam Identity can issue Credentials. As a first step we’ll create a credential issuer that will act as an authority for our example application:

```
touch examples/06-credential-exchange-issuer.rs
```

This issuer, knows a predefined list of identifiers that are member of an application’s production cluster.

In a later guide, we'll explore how Ockam enables you to define various pluggable Enrollment Protocols to decide who should be issued credentials. For this example we'll assume that this list is known in advance.

{% code lineNumbers="true" %}
```rust
use ockam::access_control::AllowAll;
use ockam::access_control::IdentityIdAccessControl;
use ockam::identity::credential_issuer::CredentialIssuer;
use ockam::identity::SecureChannelListenerOptions;
use ockam::{Context, Result, TcpListenerOptions, TcpTransport};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    let issuer = CredentialIssuer::create(&ctx).await?;
    let issuer_change_history = issuer.identity().change_history().await;
    let exported = issuer_change_history.export().unwrap();
    println!("Credential Issuer Identifier: {}", issuer.identity().identifier());
    println!("Credential Issuer Change History: {}", hex::encode(exported));

    // Tell this credential issuer about a set of public identifiers that are
    // known, in advance, to be members of the production cluster.
    let known_identifiers = vec![
        "Pe92f183eb4c324804ef4d62962dea94cf095a265d4d28500c34e1a4e0d5ef638".try_into()?,
        "Pada09e0f96e56580f6a0cb54f55ecbde6c973db6732e30dfb39b178760aed041".try_into()?,
    ];

    // Tell this credential issuer about the attributes to include in credentials
    // that will be issued to each of the above known_identifiers, after and only
    // if, they authenticate with their corresponding latest private key.
    //
    // Since this issuer knows that the above identifiers are for members of the
    // production cluster, it will issue a credential that attests to the attribute
    // set: [{cluster, production}] for all identifiers in the above list.
    //
    // For a different application this attested attribute set can be different and
    // distinct for each identifier, but for this example we'll keep things simple.
    for identifier in known_identifiers.iter() {
        issuer.put_attribute_value(&identifier, "cluster", "production").await?;
    }

    // Start a secure channel listener that only allows channels where the identity
    // at the other end of the channel can authenticate with the latest private key
    // corresponding to one of the above known public identifiers.
    let options = SecureChannelListenerOptions::new();
    issuer.identity().create_secure_channel_listener("secure", options).await?;

    // Start a credential issuer worker that will only accept incoming requests from
    // authenticated secure channels with our known public identifiers.
    let allow_known = IdentityIdAccessControl::new(known_identifiers);
    ctx.start_worker("issuer", issuer, allow_known, AllowAll).await?;

    // Initialize TCP Transport, create a TCP listener, and wait for connections.
    let tcp = TcpTransport::create(&ctx).await?;
    tcp.listen("127.0.0.1:5000", TcpListenerOptions::new()).await?;

    // Don't call ctx.stop() here so this node runs forever.
    Ok(())
}
```
{% endcode %}

```
cargo run --example 06-credential-exchange-issuer
```

### Server



```
touch examples/06-credential-exchange-server.rs
```

{% code lineNumbers="true" %}
```rust
// This node starts a tcp listener, a secure channel listener, and an echoer worker.
// It then runs forever waiting for messages.
use hello_ockam::Echoer;
use ockam::abac::AbacAccessControl;
use ockam::access_control::AllowAll;
use ockam::authenticated_storage::AuthenticatedAttributeStorage;
use ockam::identity::credential_issuer::{CredentialIssuerApi, CredentialIssuerClient};
use ockam::identity::{Identity, SecureChannelListenerOptions, SecureChannelOptions};
use ockam::{route, vault::Vault, Context, Result, TcpConnectionOptions, TcpListenerOptions, TcpTransport};
use std::sync::Arc;

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    // Initialize the TCP Transport
    let tcp = TcpTransport::create(&ctx).await?;
    let vault = Vault::create();

    // Create an Identity representing the server
    // Load an identity corresponding to the following public identifier
    // Pe92f183eb4c324804ef4d62962dea94cf095a265d4d28500c34e1a4e0d5ef638
    //
    // We're hard coding this specific identity because its public identifier is known
    // to the credential issuer as a member of the production cluster.
    let change_history = "01ed8a5b1303f975c1296c990d1bd3c1946cfef328de20531e3511ec5604ce0dd9000547c93239ba3d818ec26c9cdadd2a35cbdf1fa3b6d1a731e06164b1079fb7b8084f434b414d5f524b03012000000020e8c328bc0cc07a374762091d037e69c36fdd4d2e1a651abd4d43a1362d3f800503010140a349968063d7337d0c965969fa9c640824c01a6d37fe130d4ab963b0271b9d5bbf0923faa5e27f15359554f94f08676df01b99d997944e4feaf0caaa1189480e";
    let secret = "5b2b3f2abbd1787704d8f8b363529f8e2d8f423b6dd4b96a2c462e4f0e04ee18";
    let server = Identity::create_identity_with_change_history(&ctx, vault, change_history, secret).await?;
    let store = server.authenticated_storage();

    // Connect with the credential issuer and authenticate using the latest private
    // key of this program's hardcoded identity.
    //
    // The credential issuer already knows the public identifier of this identity
    // as a member of the production cluster so it returns a signed credential
    // attesting to that knowledge.
    let issuer_connection = tcp.connect("127.0.0.1:5000", TcpConnectionOptions::new()).await?;
    let issuer_channel = server
        .create_secure_channel(route![issuer_connection, "secure"], SecureChannelOptions::new())
        .await?;
    let issuer = CredentialIssuerClient::new(&ctx, route![issuer_channel]).await?;
    let credential = issuer.get_credential(server.identifier()).await?.unwrap();
    println!("Credential:\n{credential}");
    server.set_credential(credential).await;

    // Start an echoer worker that will only accept incoming requests from
    // identities that have authenticated credentials issued by the above credential
    // issuer. These credentials must also attest that requesting identity is
    // a member of the production cluster.
    let allow_production = AbacAccessControl::create(store.clone(), "cluster", "production");
    ctx.start_worker("echoer", Echoer, allow_production, AllowAll).await?;

    // Start a worker which will receive credentials sent by the client and issued by the issuer node
    let issuer_identity = issuer.public_identity().await?;
    let storage = Arc::new(AuthenticatedAttributeStorage::new(store.clone()));
    server
        .start_credential_exchange_worker(vec![issuer_identity], "credentials", true, storage)
        .await?;

    // Start a secure channel listener that only allows channels with
    // authenticated identities.
    server.create_secure_channel_listener("secure", SecureChannelListenerOptions::new()).await?;

    // Create a TCP listener and wait for incoming connections
    tcp.listen("127.0.0.1:4000", TcpListenerOptions::new()).await?;

    // Don't call ctx.stop() here so this node runs forever.
    Ok(())
}
```
{% endcode %}

```
cargo run --example 06-credential-exchange-server
```

### Client

```
touch examples/06-credential-exchange-client.rs
```

{% code lineNumbers="true" %}
```rust
use ockam::authenticated_storage::AuthenticatedAttributeStorage;
use ockam::identity::credential_issuer::{CredentialIssuerApi, CredentialIssuerClient};
use ockam::identity::{Identity, SecureChannelOptions};
use ockam::{route, vault::Vault, Context, Result, TcpConnectionOptions, TcpTransport};
use std::sync::Arc;

#[ockam::node]
async fn main(mut ctx: Context) -> Result<()> {
    // Initialize the TCP Transport
    let tcp = TcpTransport::create(&ctx).await?;

    // Create an Identity representing the client
    // We preload the client vault with a change history and secret key corresponding to the identity identifier
    // Pe92f183eb4c324804ef4d62962dea94cf095a265d4d28500c34e1a4e0d5ef638
    // which is an identifier known to the credential issuer, with some preset attributes
    let vault = Vault::create();

    // Create an Identity representing the server
    // Load an identity corresponding to the following public identifier
    // Pada09e0f96e56580f6a0cb54f55ecbde6c973db6732e30dfb39b178760aed041
    //
    // We're hard coding this specific identity because its public identifier is known
    // to the credential issuer as a member of the production cluster.
    let change_history = "01dcf392551f796ef1bcb368177e53f9a5875a962f67279259207d24a01e690721000547c93239ba3d818ec26c9cdadd2a35cbdf1fa3b6d1a731e06164b1079fb7b8084f434b414d5f524b03012000000020a0d205f09cab9a9467591fcee560429aab1215d8136e5c985a6b7dc729e6f08203010140b098463a727454c0e5292390d8f4cbd4dd0cae5db95606832f3d0a138936487e1da1489c40d8a0995fce71cc1948c6bcfd67186467cdd78eab7e95c080141505";
    let secret = "41b6873b20d95567bf958e6bab2808e9157720040882630b1bb37a72f4015cd2";
    let client = Identity::create_identity_with_change_history(&ctx, vault, change_history, secret).await?;
    let store = client.authenticated_storage();

    // Connect with the credential issuer and authenticate using the latest private
    // key of this program's hardcoded identity.
    //
    // The credential issuer already knows the public identifier of this identity
    // as a member of the production cluster so it returns a signed credential
    // attesting to that knowledge.
    let issuer_connection = tcp.connect("127.0.0.1:5000", TcpConnectionOptions::new()).await?;
    let issuer_channel = client
        .create_secure_channel(route![issuer_connection, "secure"], SecureChannelOptions::new())
        .await?;
    let issuer_client = CredentialIssuerClient::new(&ctx, route![issuer_channel]).await?;
    let credential = issuer_client.get_credential(client.identifier()).await?.unwrap();
    println!("Credential:\n{credential}");
    client.set_credential(credential).await;

    // Create a secure channel to the node that is running the Echoer service.
    let server_connection = tcp.connect("127.0.0.1:4000", TcpConnectionOptions::new()).await?;
    let channel = client
        .create_secure_channel(route![server_connection, "secure"], SecureChannelOptions::new())
        .await?;

    // Present credentials over the secure channel
    let storage = Arc::new(AuthenticatedAttributeStorage::new(store.clone()));
    let issuer = issuer_client.public_identity().await?;
    let r = route![channel.clone(), "credentials"];
    client.present_credential_mutual(r, &[issuer], storage, None).await?;

    // Send a message to the worker at address "echoer".
    ctx.send(route![channel, "echoer"], "Hello Ockam!".to_string()).await?;

    // Wait to receive a reply and print it.
    let reply = ctx.receive::<String>().await?;
    println!("Received: {}", reply); // should print "Hello Ockam!"

    ctx.stop().await
}
```
{% endcode %}

```
cargo run --example 06-credential-exchange-client
```

