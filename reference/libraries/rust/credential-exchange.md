# Credential exchange

Secure channels allow to exchange encrypted messages that are non-repudiable: there is a cryptographic proof that the data received over secure channel has indeed be created by the identity which you created the channel with.

This doesn't mean however that this identity is trustworthy! If the message says "withdraw 1M USD from this account" you might still want to validate that the identity sending the message has the right to do so.

In order to perform this kind of verification we can associate attributes to an identity, for example `withdraw_limit=1000000` and have those attributes being authentified by a third party which you trust. The set of attributes authenticated by a third-party is called a `Credential` and possesses a few attributes:

* `attributes` a list of attribute name / attribute value
* `subject` an identity identifier (the identity possessing these attributes)
* `issuer` the identity which signed those attributes to prove their authenticity
* `created` the date/time when those attributes were signed
* `expires` the date/time until those attributes are considered valid

Let's now see an example of exchange of credentials over a secure channel.

We are first going to need to start a node acting as a `CredentialIssuer`.&#x20;

Create a new file at:

```
touch examples/06-credential-exchange-issuer.rs
```

And add the following code:

```rust
use ockam::access_control::IdentityIdAccessControl;
use ockam::identity::credential_issuer::CredentialIssuer;
use ockam::identity::TrustEveryonePolicy;
use ockam::{Context, TcpTransport};
use ockam_core::{AllowAll, Result};

/// This node starts a temporary credential issuer accessible via TCP on localhost:5000
///
/// In a real-life scenario this node would be an "Authority", a node holding
/// attributes for a number of identities and able to issue credentials signed with its own key.
///
/// The process by which we declare to that Authority which identity holds which attributes is an
/// enrollment process and would be driven by an "enroller node".
/// For the simplicity of the example provided here we preload the credential issues node with some existing attributes
/// for both Alice's and Bob's identities.
///
#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    // Initialize the TCP Transport.
    let tcp = TcpTransport::create(&ctx).await?;

    // Create a TCP listener and wait for incoming connections.
    tcp.listen("127.0.0.1:5000").await?;

    // Create a CredentialIssuer which stores attributes for Alice and Bob, knowing their identity
    let issuer = CredentialIssuer::create(&ctx).await?;
    let alice = "P529d43ac7b01e23d3818d00e083508790bfe8825714644b98134db6c1a7a6602".try_into()?;
    let bob = "P0189a2aec3799fe9d0dc0f982063022b697f18562a403eb46fa3d32be5bd31f8".try_into()?;

    issuer.put_attribute_value(&alice, "name", "alice").await?;
    issuer.put_attribute_value(&bob, "name", "bob").await?;

    // Start a secure channel listener that alice and bob can use to retrieve their credential
    issuer
        .identity()
        .create_secure_channel_listener("issuer_listener", TrustEveryonePolicy)
        .await?;
    println!("created a secure channel listener");

    ctx.start_worker(
        "issuer",
        issuer,
        IdentityIdAccessControl::new(vec![alice, bob]),
        AllowAll,
    )
    .await?;

    Ok(())
}
```

You can then start the node by running

```
cargo run --example 06-credential-exchange-issuer
```

That node starts a worker, `issuer`, which can issue credentials for both `alice` and `bob` , whose public identities are known to the issuer.&#x20;

We are now going to create a node for an identity named "bob" which will start a secure channel listener allowing "alice" to connect. Create a new file at:

```
touch examples/06-credential-exchange-bob.rs
```

And add the following code

```rust
// This node starts a tcp listener, a secure channel listener, and an echoer worker.
// It then runs forever waiting for messages.
use hello_ockam::Echoer;
use ockam::abac::AbacAccessControl;
use ockam::access_control::AllowAll;
use ockam::authenticated_storage::AuthenticatedAttributeStorage;
use ockam::identity::credential_issuer::{CredentialIssuerApi, CredentialIssuerClient};
use ockam::identity::{Identity, TrustEveryonePolicy};
use ockam::{vault::Vault, Context, Result, TcpTransport};
use ockam_core::route;

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    // Initialize the TCP Transport
    let tcp = TcpTransport::create(&ctx).await?;

    // Create an Identity representing Bob
    // We preload Bob's vault with a secret key corresponding to the identity identifier
    // P0189a2aec3799fe9d0dc0f982063022b697f18562a403eb46fa3d32be5bd31f8
    // which is an identifier known to the credential issuer, with some preset attributes
    let vault = Vault::create();
    let key_id = "0189a2aec3799fe9d0dc0f982063022b697f18562a403eb46fa3d32be5bd31f8".to_string();
    let secret = "08ddb4458a53d5493eac7e9941a1b0d06896efa2d1efac8cf225ee1ccb824458";
    let bob = Identity::create_identity_with_secret(&ctx, vault, &key_id, secret).await?;

    // Create a client to a credential issuer
    let issuer_connection = tcp.connect("127.0.0.1:5000").await?;
    let issuer_route = route![issuer_connection, "issuer_listener"];
    let issuer = CredentialIssuerClient::new(&ctx, &bob, issuer_route).await?;

    // Get a credential for Bob (this is done via a secure channel)
    let credential = issuer.get_credential(bob.identifier()).await?.unwrap();
    println!("got a credential from the issuer\n{credential}");
    bob.set_credential(credential).await;

    // Start a worker which will receive credentials sent by Alice and issued by the issuer node
    let issuer_identity = issuer.public_identity().await?;
    bob.start_credential_exchange_worker(
        vec![issuer_identity],
        "credential_exchange",
        true,
        AuthenticatedAttributeStorage::new(bob.authenticated_storage().clone()),
    )
    .await?;

    // Create a secure channel listener to allow Alice to create a secure channel to Bob's node
    bob.create_secure_channel_listener("bob_listener", TrustEveryonePolicy)
        .await?;
    println!("created a secure channel listener");

    // Start an echoer service which will only allow subjects with name = alice
    let alice_only = AbacAccessControl::create(bob.authenticated_storage(), "name", "alice");
    ctx.start_worker("echoer", Echoer, alice_only, AllowAll).await?;

    // Create a TCP listener and wait for incoming connections
    tcp.listen("127.0.0.1:4000").await?;
    println!("created a TCP listener");

    // Don't call ctx.stop() here so this node runs forever.
    Ok(())
}
```

Then start the node with:

```
cargo run --example 06-credential-exchange-bob
```

When we run this node:

* we create an identity for Bob. We make sure to initialize Bob's Vault with the private key corresponding to his public identity known by the issuer node
* we retrieve credentials for Bob from the issuer node
* we start a _credential exchange worker_ which will be ready to exchange credentials with alice over a secure channel
* we start a secure channel listener
* we start an echoer service and we specify that it is only accessible to an identity having the attribute `name=alice`&#x20;

We are now ready to create and start a node for Alice. Create first a new file at:

```
touch examples/06-credential-exchange-bob.rs
```

And add the following code:

```rust
use ockam::authenticated_storage::AuthenticatedAttributeStorage;
use ockam::identity::credential_issuer::{CredentialIssuerApi, CredentialIssuerClient};
use ockam::identity::{Identity, TrustEveryonePolicy};
use ockam::{route, vault::Vault, Context, Result, TcpTransport};

#[ockam::node]
async fn main(mut ctx: Context) -> Result<()> {
    // Initialize the TCP Transport
    let tcp = TcpTransport::create(&ctx).await?;

    // Create an Identity representing Alice
    // We preload Alice's vault with a secret key corresponding to the identity identifier
    // P529d43ac7b01e23d3818d00e083508790bfe8825714644b98134db6c1a7a6602
    // which is an identifier known to the credential issuer, with some preset attributes
    let vault = Vault::create();
    let key_id = "529d43ac7b01e23d3818d00e083508790bfe8825714644b98134db6c1a7a6602".to_string();
    let secret = "acaf50c540be1494d67aaad78aca8d22ac62c4deb4fb113991a7b30a0bd0c757";
    let alice = Identity::create_identity_with_secret(&ctx, vault, &key_id, secret).await?;

    // Create a client to the credential issuer
    let issuer_connection = tcp.connect("127.0.0.1:5000").await?;
    let issuer_route = route![issuer_connection, "issuer_listener"];
    let issuer = CredentialIssuerClient::new(&ctx, &alice, issuer_route).await?;

    // Get a credential for Alice (this is done via a secure channel)
    let credential = issuer.get_credential(alice.identifier()).await?.unwrap();
    println!("got a credential from the issuer\n{credential}");
    alice.set_credential(credential).await;

    // Create a secure channel to Bob's node
    let bob_connection = tcp.connect("127.0.0.1:4000").await?;
    let channel = alice
        .create_secure_channel(route![bob_connection, "bob_listener"], TrustEveryonePolicy)
        .await?;
    println!("created a secure channel at {channel:?}");

    // Send Alice credentials over the secure channel
    alice
        .present_credential_mutual(
            route![channel.clone(), "credential_exchange"],
            vec![&issuer.public_identity().await?],
            &AuthenticatedAttributeStorage::new(alice.authenticated_storage().clone()),
            None,
        )
        .await?;
    println!("exchange done!");

    // The echoer service should now be accessible to Alice because she
    // presented the right credentials to Bob
    let received: String = ctx
        .send_and_receive(route![channel, "echoer"], "Hello!".to_string())
        .await?;
    println!("{received}");

    ctx.stop().await
}
```

Then start Alice's node with:

```
cargo run --example 06-credential-exchange-alice
```

When that node starts:

* we create an identity for Alice. We make sure to initialize Alice's Vault with the private key corresponding to her public identity known by the issuer node
* we retrieve credentials for Alice from the issuer node
* we start a secure channel to Bob's node&#x20;
* we proceed to a credential exchange (by connecting to the credential exchange worker on Bob's node)
* we finally send a message to the echoer service on Bob's node to verify that we can indeed access that service

And when that node has finished running you should see:

```
"Hello!"
```

Which is the message returned by the echoer service on Bob's node. That message has been returned after Bob was able to verify Alice's credential (from an issuer that he trusts) and use the attributes contained in the credential to validate the access to the echoer service (using the `AbacAccessControl` check).
