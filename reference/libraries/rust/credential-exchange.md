---
description: >-
  Scale mutual trust using lightweight, short-lived, revokable, attribute-based
  credentials.
---

# Credentials and Authorities

### Setup

[setup](./#get-started) and create an [echoer worker](nodes.md#echoer-worker)

```
cargo add hex
```

### Credential Issuer

```
touch examples/06-credential-exchange-issuer.rs
```

{% code lineNumbers="true" %}
```rust
use hex;

use ockam::access_control::{AllowAll, IdentityIdAccessControl};
use ockam::identity::credential_issuer::CredentialIssuer;
use ockam::identity::TrustEveryonePolicy;
use ockam::{Context, Result, TcpTransport};

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
        "P529d43ac7b01e23d3818d00e083508790bfe8825714644b98134db6c1a7a6602".try_into()?,
        "P0189a2aec3799fe9d0dc0f982063022b697f18562a403eb46fa3d32be5bd31f8".try_into()?,
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
    let p = TrustEveryonePolicy;
    issuer.identity().create_secure_channel_listener("secure", p).await?;

    // Start a credential issuer worker that will only accept incoming requests from
    // authenticated secure channels with our known public identifiers.
    let allow_known = IdentityIdAccessControl::new(known_identifiers);
    ctx.start_worker("issuer", issuer, allow_known, AllowAll).await?;

    // Initialize TCP Transport, create a TCP listener, and wait for connections.
    let tcp = TcpTransport::create(&ctx).await?;
    tcp.listen("127.0.0.1:5000").await?;

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
use hello_ockam::Echoer;
use std::io;

use ockam::abac::AbacAccessControl;
use ockam::access_control::AllowAll;
use ockam::authenticated_storage::AuthenticatedAttributeStorage;
use ockam::identity::credential_issuer::{CredentialIssuerApi, CredentialIssuerClient};
use ockam::identity::{Identity, PublicIdentity, TrustEveryonePolicy};
use ockam::vault::Vault;
use ockam::{route, Context, Result, TcpTransport};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    let tcp = TcpTransport::create(&ctx).await?;
    let vault = Vault::create();

    // Ask for Credential Issuer's Change History to be input on standard input
    // The Change History represents the full history of public identifiers and
    // public keys used by the Issuer.
    //
    // Later in this program we'll use this history of public keys to decide
    // who will be allowed to access the Echoer service provided by this server.
    println!("\nEnter the Credential Issuer's Change History: ");
    let mut h = String::new();
    io::stdin().read_line(&mut h).expect("Error reading from stdin.");
    let issuer_change_history = hex::decode(h.trim()).expect("Error decoding hex input.");
    let issuer = PublicIdentity::import(issuer_change_history.as_slice(), &vault).await?;
    println!("Credential Issuer Identifier: {}", issuer.identifier());

    // Load a hardcoded secret key corresponding to the following public identifier
    // P0189a2aec3799fe9d0dc0f982063022b697f18562a403eb46fa3d32be5bd31f8
    //
    // We're hard coding this specific identity bacause its public identifier is known
    // to the credential issuer as a member of the production cluster.
    let key_id = "0189a2aec3799fe9d0dc0f982063022b697f18562a403eb46fa3d32be5bd31f8".to_string();
    let secret = "08ddb4458a53d5493eac7e9941a1b0d06896efa2d1efac8cf225ee1ccb824458";
    let identity = Identity::create_identity_with_secret(&ctx, vault, &key_id, secret).await?;
    let store = identity.authenticated_storage();

    // Connect with the credential issuer and authenticate using the latest private
    // key of this program's hardcoded identity.
    //
    // The credential issuer already knows the public identifier of this identity
    // as a member of the production cluster so it returns a signed credential
    // attesting to that knowledge.
    let issuer_connection = tcp.connect("127.0.0.1:5000").await?;
    let issuer_route = route![issuer_connection, "secure"];
    let issuer_client = CredentialIssuerClient::new(&ctx, &identity, issuer_route).await?;
    let credential = issuer_client.get_credential(identity.identifier()).await?.unwrap();
    println!("Credential: {}", credential.clone());
    identity.set_credential(credential).await;

    // Start an echoer worker that will only accept incoming requests from
    // identities that have authenticated credentials issued by the above credential
    // issuer. These credentials must also attest that requesting identity is
    // a member of the production cluster.
    let allow_production = AbacAccessControl::create(store, "cluster", "production");
    ctx.start_worker("echoer", Echoer, allow_production, AllowAll).await?;

    // Start a credential exchange worker that will present credentials issued
    // to this server's hardcoded identity and authenticate credentials issued by
    // the user supplied issuer public identity.
    let s = AuthenticatedAttributeStorage::new(store.clone());
    identity.start_credential_exchange_worker(vec![issuer], "credentials", true, s).await?;

    // Start a secure channel listener that only allows channels with
    // authenticated identities.
    let policy = TrustEveryonePolicy;
    identity.create_secure_channel_listener("secure", policy).await?;

    // Create a TCP listener, and wait for connections.
    tcp.listen("127.0.0.1:4000").await?;

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
use std::io;

use ockam::authenticated_storage::AuthenticatedAttributeStorage;
use ockam::identity::credential_issuer::{CredentialIssuerApi, CredentialIssuerClient};
use ockam::identity::{Identity, PublicIdentity, TrustEveryonePolicy};
use ockam::vault::Vault;
use ockam::{route, Context, Result, TcpTransport};

#[ockam::node]
async fn main(mut ctx: Context) -> Result<()> {
    // Intialize the TCP Transport
    let tcp = TcpTransport::create(&ctx).await?;
    let vault = Vault::create();

    println!("\nEnter the identifier change history of the issuer: ");
    let mut h = String::new();
    io::stdin().read_line(&mut h).expect("Error reading from stdin.");
    let issuer_change_history = hex::decode(h.trim()).expect("Error decoding hex input.");
    let issuer = PublicIdentity::import(issuer_change_history.as_slice(), &vault).await?;
    println!("Credential Issuer Identifier: {}", issuer.identifier());

    // Load a hardcoded secret key corresponding to the following public identifier
    // P529d43ac7b01e23d3818d00e083508790bfe8825714644b98134db6c1a7a6602
    //
    // We're hard coding this specific identity bacause its public identifier is known
    // to the credential issuer as a member of the production cluster.
    let key_id = "529d43ac7b01e23d3818d00e083508790bfe8825714644b98134db6c1a7a6602".to_string();
    let secret = "acaf50c540be1494d67aaad78aca8d22ac62c4deb4fb113991a7b30a0bd0c757";
    let identity = Identity::create_identity_with_secret(&ctx, vault, &key_id, secret).await?;

    // Connect with the credential issuer and authenticate using the latest private
    // key of this program's hardcoded identity.
    //
    // The credential issuer already knows the public identifier of this identity
    // as a member of the production cluster so it returns a signed credential
    // attesting to that knowledge.
    let issuer_connection = tcp.connect("127.0.0.1:5000").await?;
    let issuer_route = route![issuer_connection, "secure"];
    let issuer_client = CredentialIssuerClient::new(&ctx, &identity, issuer_route).await?;
    let credential = issuer_client.get_credential(identity.identifier()).await?.unwrap();
    println!("Credential: {}", credential.clone());
    identity.set_credential(credential).await;

    // Create a secure channel to the node that is running the Echoer service.
    let server_connection = tcp.connect("127.0.0.1:4000").await?;
    let server_route = route![server_connection, "secure"];
    let policy = TrustEveryonePolicy;
    let channel = identity.create_secure_channel(server_route, policy).await?;

    // Present credentials over the secure channel
    let r = route![channel.clone(), "credentials"];
    let s = &AuthenticatedAttributeStorage::new(identity.authenticated_storage().clone());
    identity.present_credential_mutual(r, vec![&issuer], s, None).await?;

    // Send a message to the worker at address "echoer".
    ctx.send(route![channel, "echoer"], "Hello Ockam!".to_string()).await?;

    // Wait to receive a reply and print it.
    let reply = ctx.receive::<String>().await?;
    println!("Received: {}", reply); // should print "Hello Ockam!"

    // Don't call ctx.stop() here so this node runs forever.
    Ok(())
}

```
{% endcode %}

```
cargo run --example 06-credential-exchange-client
```

