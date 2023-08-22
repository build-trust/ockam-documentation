---
description: >-
  Scale mutual trust using lightweight, short-lived, revokable, attribute-based
  credentials.
---

# Credentials and Authorities

Ockam Secure Channels enable you to setup mutually authenticated and end-to-end encrypted communication. Once a channel is established, it has the following guarantees:

1. **Authenticity:** Each end of the channel knows that messages received on the channel must have been sent by someone who possesses the secret keys of specific Ockam Cryptographic Identifier.
2. **Integrity:** Each end of the channel knows that the messages received on the channel could not have been tapered en-route and are exactly what was sent by the authenticated sender at the other end of the channel.
3. **Confidentiality:** Each end of the channel knows that the contents of messages received on the channel could not have been observed en-route between the sender and the receiver.

These guarantees however don't automatically imply trust. They don't tell us if a particular sender is trusted to inform us about a particular topic or if the sender is authorized to get a response to a particular request.

One way to create trust and authorize requests would be to use Access Control Lists (ACLs), where every receiver of messages would have a preconfigured list of identifiers that are trusted to inform about a certain topic or trigger certain requests. This approach works but doesn't scale very well. It becomes very cumbersome to manage mutual trust if you have more that a few nodes communicating with each other.

Another, and significantly more scalable, approach is to use Ockam <mark style="color:orange;">Credentials</mark> combined with <mark style="color:orange;">Attribute Based Access Control (ABAC)</mark>. In this setup every participant starts off by trusting a single Credential Issuer to be the authority on the attributes of an Identifier. This authority issues cryptographically signed credentials to attest to these attributes. Participants can then exchange and authenticate each others’ credentials to collect authenticated attributes about an identifier. Every participant uses these authenticated attributes to make authorization decisions based on attribute-based access control policies.

Let’s walk through an example of setting up ABAC using cryptographically verifiable credentials.

### Setup

To get started please create the initial [<mark style="color:blue;">`hello_ockam` project</mark>](./#get-started) and define an [<mark style="color:blue;">`echoer` worker</mark>](nodes.md#echoer-worker). We'll also need the `hex` crate for this example so add that to your `Cargo.toml` using `cargo add` :

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
// examples/06-credentials-exchange-issuer.rs
use ockam::access_control::AllowAll;
use ockam::access_control::IdentityIdAccessControl;
use ockam::identity::CredentialsIssuer;
use ockam::identity::SecureChannelListenerOptions;
use ockam::vault::{Secret, SecretAttributes, SoftwareSigningVault, Vault};
use ockam::{Context, Result, TcpListenerOptions};
use ockam::{Node, TcpTransportExtension};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    let signing_vault = SoftwareSigningVault::create();
    // Import the signing secret key to the Vault
    let secret = signing_vault
        .import_key(
            Secret::new(hex::decode("0127359911708ef4de9adaaf27c357501473c4a10a5326a69c1f7f874a0cd82e").unwrap()),
            SecretAttributes::Ed25519,
        )
        .await?;

    // Create a default Vault but use the signing vault with our secret in it
    let mut vault = Vault::create();
    vault.signing_vault = signing_vault;

    let node = Node::builder().with_vault(vault).build(ctx).await?;

    let issuer_identity = hex::decode("81a201583ba20101025835a4028201815820afbca9cf5d440147450f9f0d0a038a337b3fe5c17086163f2c54509558b62ef403f4041a64dd404a051a77a9434a0282018158407754214545cda6e7ff49136f67c9c7973ec309ca4087360a9f844aac961f8afe3f579a72c0c9530f3ff210f02b7c5f56e96ce12ee256b01d7628519800723805").unwrap();
    let issuer = node.import_private_identity(&issuer_identity, &secret).await?;
    println!("issuer identifier {}", issuer.identifier());

    // Tell the credential issuer about a set of public identifiers that are
    // known, in advance, to be members of the production cluster.
    let known_identifiers = vec![
        "I6342c580429b9a0733880bea4fa18f8055871130".try_into()?, // Client Identifier
        "I2c3b0ef15c12fe43d405497fcfc46318da46d0f5".try_into()?, // Server Identifier
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
    let credential_issuer = CredentialsIssuer::new(
        node.identities().repository(),
        node.credentials(),
        issuer.identifier(),
        "trust_context".into(),
    )
    .await?;
    for identifier in known_identifiers.iter() {
        node.identities()
            .repository()
            .put_attribute_value(identifier, b"cluster".to_vec(), b"production".to_vec())
            .await?;
    }

    let tcp_listener_options = TcpListenerOptions::new();
    let sc_listener_options =
        SecureChannelListenerOptions::new().as_consumer(&tcp_listener_options.spawner_flow_control_id());
    let sc_listener_flow_control_id = sc_listener_options.spawner_flow_control_id();

    // Start a secure channel listener that only allows channels where the identity
    // at the other end of the channel can authenticate with the latest private key
    // corresponding to one of the above known public identifiers.
    node.create_secure_channel_listener(issuer.identifier(), "secure", sc_listener_options)
        .await?;

    // Start a credential issuer worker that will only accept incoming requests from
    // authenticated secure channels with our known public identifiers.
    let allow_known = IdentityIdAccessControl::new(known_identifiers);
    node.flow_controls()
        .add_consumer("issuer", &sc_listener_flow_control_id);
    node.start_worker_with_access_control("issuer", credential_issuer, allow_known, AllowAll)
        .await?;

    // Initialize TCP Transport, create a TCP listener, and wait for connections.
    let tcp = node.create_tcp_transport().await?;
    tcp.listen("127.0.0.1:5000", tcp_listener_options).await?;

    // Don't call node.stop() here so this node runs forever.
    println!("issuer started");
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
// examples/06-credentials-exchange-server.rs
// This node starts a tcp listener, a secure channel listener, and an echoer worker.
// It then runs forever waiting for messages.
use hello_ockam::Echoer;
use ockam::abac::AbacAccessControl;
use ockam::access_control::AllowAll;
use ockam::identity::{
    AuthorityService, CredentialsIssuerClient, SecureChannelListenerOptions, SecureChannelOptions, TrustContext,
};
use ockam::vault::{Secret, SecretAttributes, SoftwareSigningVault, Vault};
use ockam::{route, Context, Result, TcpConnectionOptions, TcpListenerOptions};
use ockam::{Node, TcpTransportExtension};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    let signing_vault = SoftwareSigningVault::create();
    // Import the signing secret key to the Vault
    let secret = signing_vault
        .import_key(
            Secret::new(hex::decode("5FB3663DF8405379981462BABED7507E3D53A8D061188105E3ADBD70E0A74B8A").unwrap()),
            SecretAttributes::Ed25519,
        )
        .await?;

    // Create a default Vault but use the signing vault with our secret in it
    let mut vault = Vault::create();
    vault.signing_vault = signing_vault;

    let node = Node::builder().with_vault(vault).build(ctx).await?;

    // Initialize the TCP Transport
    let tcp = node.create_tcp_transport().await?;

    // Create an Identity representing the server
    // Load an identity corresponding to the following public identifier
    // I2c3b0ef15c12fe43d405497fcfc46318da46d0f5
    //
    // We're hard coding this specific identity because its public identifier is known
    // to the credential issuer as a member of the production cluster.
    let change_history = hex::decode("81a201583ba20101025835a40282018158201d387ce453816d91159740a55e9a62ad3b58be9ecf7ef08760c42c0d885b6c2e03f4041a64dd4074051a77a9437402820181584053de69d82c9c4b12476c889b437be1d9d33bd0041655c4836a3a57ac5a67703e7f500af5bacaed291cfd6783d255fe0f0606638577d087a5612bfb4671f2b70a").unwrap();
    let server = node.import_private_identity(&change_history, &secret).await?;

    // Connect with the credential issuer and authenticate using the latest private
    // key of this program's hardcoded identity.
    //
    // The credential issuer already knows the public identifier of this identity
    // as a member of the production cluster so it returns a signed credential
    // attesting to that knowledge.
    let issuer_connection = tcp.connect("127.0.0.1:5000", TcpConnectionOptions::new()).await?;
    let issuer_channel = node
        .create_secure_channel(
            server.identifier(),
            route![issuer_connection, "secure"],
            SecureChannelOptions::new(),
        )
        .await?;

    let issuer_client = CredentialsIssuerClient::new(route![issuer_channel, "issuer"], node.context()).await?;
    let credential = issuer_client.credential().await?;

    // Verify that the received credential has indeed be signed by the issuer.
    // The issuer identity must be provided out-of-band from a trusted source
    // and match the identity used to start the issuer node
    let issuer_identity = "81a201583ba20101025835a4028201815820afbca9cf5d440147450f9f0d0a038a337b3fe5c17086163f2c54509558b62ef403f4041a64dd404a051a77a9434a0282018158407754214545cda6e7ff49136f67c9c7973ec309ca4087360a9f844aac961f8afe3f579a72c0c9530f3ff210f02b7c5f56e96ce12ee256b01d7628519800723805";
    let issuer = node.import_identity_hex(issuer_identity).await?;
    node.credentials()
        .verify_credential(Some(server.identifier()), &[issuer.identifier().clone()], &credential)
        .await?;

    // Create a trust context that will be used to authenticate credential exchanges
    let trust_context = TrustContext::new(
        "trust_context_id".to_string(),
        Some(AuthorityService::new(
            node.credentials(),
            issuer.identifier().clone(),
            None,
        )),
    );

    // Start an echoer worker that will only accept incoming requests from
    // identities that have authenticated credentials issued by the above credential
    // issuer. These credentials must also attest that requesting identity is
    // a member of the production cluster.
    let tcp_listener_options = TcpListenerOptions::new();
    let sc_listener_options = SecureChannelListenerOptions::new()
        .with_trust_context(trust_context)
        .with_credential(credential)
        .as_consumer(&tcp_listener_options.spawner_flow_control_id());

    node.flow_controls()
        .add_consumer("echoer", &sc_listener_options.spawner_flow_control_id());
    let allow_production = AbacAccessControl::create(node.repository(), "cluster", "production");
    node.start_worker_with_access_control("echoer", Echoer, allow_production, AllowAll)
        .await?;

    // Start a secure channel listener that only allows channels with
    // authenticated identities.
    node.create_secure_channel_listener(server.identifier(), "secure", sc_listener_options)
        .await?;

    // Create a TCP listener and wait for incoming connections
    tcp.listen("127.0.0.1:4000", tcp_listener_options).await?;

    // Don't call node.stop() here so this node runs forever.
    println!("server started");
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
// examples/06-credentials-exchange-client.rs
use ockam::identity::{AuthorityService, CredentialsIssuerClient, SecureChannelOptions, TrustContext};
use ockam::vault::{Secret, SecretAttributes, SoftwareSigningVault, Vault};
use ockam::{route, Context, Result, TcpConnectionOptions};
use ockam::{Node, TcpTransportExtension};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    let signing_vault = SoftwareSigningVault::create();
    // Import the signing secret key to the Vault
    let secret = signing_vault
        .import_key(
            Secret::new(hex::decode("31FF4E1CD55F17735A633FBAB4B838CF88D1252D164735CB3185A6E315438C2C").unwrap()),
            SecretAttributes::Ed25519,
        )
        .await?;

    // Create a default Vault but use the signing vault with our secret in it
    let mut vault = Vault::create();
    vault.signing_vault = signing_vault;

    let mut node = Node::builder().with_vault(vault).build(ctx).await?;
    // Initialize the TCP Transport
    let tcp = node.create_tcp_transport().await?;

    // Create an Identity representing the client
    // We preload the client vault with a change history and secret key corresponding to the identity identifier
    // I6342c580429b9a0733880bea4fa18f8055871130
    // which is an identifier known to the credential issuer, with some preset attributes
    //
    // We're hard coding this specific identity because its public identifier is known
    // to the credential issuer as a member of the production cluster.
    let change_history = hex::decode("81a201583ba20101025835a4028201815820530d1c2e9822433b679a66a60b9c2ed47c370cd0ce51cbe1a7ad847b5835a96303f4041a64dd4060051a77a94360028201815840042fff8f6c80603fb1cec4a3cf1ff169ee36889d3ed76184fe1dfbd4b692b02892df9525c61c2f1286b829586d13d5abf7d18973141f734d71c1840520d40a0e").unwrap();
    let client = node.import_private_identity(&change_history, &secret).await?;
    println!("issuer identifier {}", client.identifier());

    // Connect with the credential issuer and authenticate using the latest private
    // key of this program's hardcoded identity.
    //
    // The credential issuer already knows the public identifier of this identity
    // as a member of the production cluster so it returns a signed credential
    // attesting to that knowledge.
    let issuer_connection = tcp.connect("127.0.0.1:5000", TcpConnectionOptions::new()).await?;
    let issuer_channel = node
        .create_secure_channel(
            client.identifier(),
            route![issuer_connection, "secure"],
            SecureChannelOptions::new(),
        )
        .await?;

    let issuer_client = CredentialsIssuerClient::new(route![issuer_channel, "issuer"], node.context()).await?;
    let credential = issuer_client.credential().await?;

    // Verify that the received credential has indeed be signed by the issuer.
    // The issuer identity must be provided out-of-band from a trusted source
    // and match the identity used to start the issuer node
    let issuer_identity = "81a201583ba20101025835a4028201815820afbca9cf5d440147450f9f0d0a038a337b3fe5c17086163f2c54509558b62ef403f4041a64dd404a051a77a9434a0282018158407754214545cda6e7ff49136f67c9c7973ec309ca4087360a9f844aac961f8afe3f579a72c0c9530f3ff210f02b7c5f56e96ce12ee256b01d7628519800723805";
    let issuer = node.import_identity_hex(issuer_identity).await?;
    node.credentials()
        .verify_credential(Some(client.identifier()), &[issuer.identifier().clone()], &credential)
        .await?;

    // Create a trust context that will be used to authenticate credential exchanges
    let trust_context = TrustContext::new(
        "trust_context_id".to_string(),
        Some(AuthorityService::new(
            node.credentials(),
            issuer.identifier().clone(),
            None,
        )),
    );

    // Create a secure channel to the node that is running the Echoer service.
    let server_connection = tcp.connect("127.0.0.1:4000", TcpConnectionOptions::new()).await?;
    let channel = node
        .create_secure_channel(
            client.identifier(),
            route![server_connection, "secure"],
            SecureChannelOptions::new()
                .with_trust_context(trust_context)
                .with_credential(credential),
        )
        .await?;

    // Send a message to the worker at address "echoer".
    // Wait to receive a reply and print it.
    let reply = node
        .send_and_receive::<String>(route![channel, "echoer"], "Hello Ockam!".to_string())
        .await?;
    println!("Received: {}", reply); // should print "Hello Ockam!"

    node.stop().await
}

```
{% endcode %}

```
cargo run --example 06-credential-exchange-client
```
