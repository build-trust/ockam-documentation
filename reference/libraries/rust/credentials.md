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

To get started please create the initial [<mark style="color:blue;">`hello_ockam`</mark> <mark style="color:blue;"></mark><mark style="color:blue;">project</mark>](./#get-started) and define an [<mark style="color:blue;">`echoer`</mark> <mark style="color:blue;"></mark><mark style="color:blue;">worker</mark>](nodes.md#echoer-worker). We'll also need the `hex` crate for this example so add that to your `Cargo.toml` using `cargo add` :

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
use ockam::compat::collections::BTreeMap;
use ockam::compat::sync::Arc;
use ockam::identity::utils::now;
use ockam::identity::SecureChannelListenerOptions;
use ockam::identity::{Identifier, Vault};
use ockam::vault::{EdDSACurve25519SecretKey, SigningSecret, SoftwareVaultForSigning};
use ockam::{Context, Result, TcpListenerOptions};
use ockam::{Node, TcpTransportExtension};
use ockam_api::authenticator::credential_issuer::CredentialIssuerWorker;
use ockam_api::authenticator::{AuthorityMembersRepository, AuthorityMembersSqlxDatabase, PreTrustedIdentity};
use ockam_api::DefaultAddress;

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    let identity_vault = SoftwareVaultForSigning::create().await?;
    // Import the signing secret key to the Vault
    let secret = identity_vault
        .import_key(SigningSecret::EdDSACurve25519(EdDSACurve25519SecretKey::new(
            hex::decode("0127359911708ef4de9adaaf27c357501473c4a10a5326a69c1f7f874a0cd82e")
                .unwrap()
                .try_into()
                .unwrap(),
        )))
        .await?;

    // Create a default Vault but use the signing vault with our secret in it
    let mut vault = Vault::create().await?;
    vault.identity_vault = identity_vault;

    let node = Node::builder().await?.with_vault(vault).build(&ctx).await?;

    let issuer_identity = hex::decode("81825837830101583285f68200815820afbca9cf5d440147450f9f0d0a038a337b3fe5c17086163f2c54509558b62ef4f41a654cf97d1a7818fc7d8200815840650c4c939b96142546559aed99c52b64aa8a2f7b242b46534f7f8d0c5cc083d2c97210b93e9bca990e9cb9301acc2b634ffb80be314025f9adc870713e6fde0d").unwrap();
    let issuer = node.import_private_identity(None, &issuer_identity, &secret).await?;
    println!("issuer identifier {}", issuer);

    // Tell the credential issuer about a set of public identifiers that are
    // known, in advance, to be members of the production cluster.
    let known_identifiers = vec![
        Identifier::try_from("Ie70dc5545d64724880257acb32b8851e7dd1dd57076838991bc343165df71bfe")?, // Client Identifier
        Identifier::try_from("Ife42b412ecdb7fda4421bd5046e33c1017671ce7a320c3342814f0b99df9ab60")?, // Server Identifier
    ];

    let members = Arc::new(AuthorityMembersSqlxDatabase::create().await?);

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
    let credential_issuer = CredentialIssuerWorker::new(members.clone(), node.credentials(), &issuer, None, None);

    let mut pre_trusted_identities = BTreeMap::<Identifier, PreTrustedIdentity>::new();
    let attributes = PreTrustedIdentity::new(
        [(b"cluster".to_vec(), b"production".to_vec())].into(),
        now()?,
        None,
        issuer.clone(),
    );
    for identifier in &known_identifiers {
        pre_trusted_identities.insert(identifier.clone(), attributes.clone());
    }
    members
        .bootstrap_pre_trusted_members(&pre_trusted_identities.into())
        .await?;

    let tcp_listener_options = TcpListenerOptions::new();
    let sc_listener_options =
        SecureChannelListenerOptions::new().as_consumer(&tcp_listener_options.spawner_flow_control_id());
    let sc_listener_flow_control_id = sc_listener_options.spawner_flow_control_id();

    // Start a secure channel listener that only allows channels where the identity
    // at the other end of the channel can authenticate with the latest private key
    // corresponding to one of the above known public identifiers.
    node.create_secure_channel_listener(&issuer, DefaultAddress::SECURE_CHANNEL_LISTENER, sc_listener_options)
        .await?;

    // Start a credential issuer worker that will only accept incoming requests from
    // authenticated secure channels with our known public identifiers.
    let allow_known = IdentityIdAccessControl::new(known_identifiers);
    node.flow_controls()
        .add_consumer(DefaultAddress::CREDENTIAL_ISSUER, &sc_listener_flow_control_id);
    node.start_worker_with_access_control(
        DefaultAddress::CREDENTIAL_ISSUER,
        credential_issuer,
        allow_known,
        AllowAll,
    )
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
use ockam::identity::{SecureChannelListenerOptions, Vault};
use ockam::vault::{EdDSACurve25519SecretKey, SigningSecret, SoftwareVaultForSigning};
use ockam::{Context, Result, TcpListenerOptions};
use ockam::{Node, TcpTransportExtension};
use ockam_api::enroll::enrollment::Enrollment;
use ockam_api::nodes::NodeManager;
use ockam_api::DefaultAddress;
use ockam_multiaddr::MultiAddr;

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    let identity_vault = SoftwareVaultForSigning::create().await?;
    // Import the signing secret key to the Vault
    let secret = identity_vault
        .import_key(SigningSecret::EdDSACurve25519(EdDSACurve25519SecretKey::new(
            hex::decode("5FB3663DF8405379981462BABED7507E3D53A8D061188105E3ADBD70E0A74B8A")
                .unwrap()
                .try_into()
                .unwrap(),
        )))
        .await?;

    // Create a default Vault but use the signing vault with our secret in it
    let mut vault = Vault::create().await?;
    vault.identity_vault = identity_vault;

    let node = Node::builder().await?.with_vault(vault).build(&ctx).await?;

    // Initialize the TCP Transport
    let tcp = node.create_tcp_transport().await?;

    // Create an Identity representing the server
    // Load an identity corresponding to the following public identifier
    // Ife42b412ecdb7fda4421bd5046e33c1017671ce7a320c3342814f0b99df9ab60
    //
    // We're hard coding this specific identity because its public identifier is known
    // to the credential issuer as a member of the production cluster.
    let change_history = hex::decode("81825837830101583285f682008158201d387ce453816d91159740a55e9a62ad3b58be9ecf7ef08760c42c0d885b6c2ef41a654cf9681a7818fc688200815840dc10ba498655dac0ebab81c6e1af45f465408ddd612842f10a6ced53c06d4562117e14d656be85685aa5bfbd5e5ede6f0ecf5eb41c19a5594e7a25b7a42c5c07").unwrap();
    let server = node.import_private_identity(None, &change_history, &secret).await?;

    let issuer_identity = "81825837830101583285f68200815820afbca9cf5d440147450f9f0d0a038a337b3fe5c17086163f2c54509558b62ef4f41a654cf97d1a7818fc7d8200815840650c4c939b96142546559aed99c52b64aa8a2f7b242b46534f7f8d0c5cc083d2c97210b93e9bca990e9cb9301acc2b634ffb80be314025f9adc870713e6fde0d";
    let issuer = node.import_identity_hex(None, issuer_identity).await?;

    // Connect with the credential issuer and authenticate using the latest private
    // key of this program's hardcoded identity.
    //
    // The credential issuer already knows the public identifier of this identity
    // as a member of the production cluster so it returns a signed credential
    // attesting to that knowledge.
    let authority_node = NodeManager::authority_node_client(
        &tcp,
        node.secure_channels().clone(),
        &issuer,
        &MultiAddr::try_from("/dnsaddr/localhost/tcp/5000/secure/api").unwrap(),
        &server,
    )
    .await?;
    let credential = authority_node.issue_credential(node.context()).await.unwrap();

    // Verify that the received credential has indeed be signed by the issuer.
    // The issuer identity must be provided out-of-band from a trusted source
    // and match the identity used to start the issuer node
    node.credentials()
        .credentials_verification()
        .verify_credential(Some(&server), &[issuer.clone()], &credential)
        .await?;

    // Start an echoer worker that will only accept incoming requests from
    // identities that have authenticated credentials issued by the above credential
    // issuer. These credentials must also attest that requesting identity is
    // a member of the production cluster.
    let tcp_listener_options = TcpListenerOptions::new();
    let sc_listener_options = SecureChannelListenerOptions::new()
        .with_authority(issuer.clone())
        .with_credential(credential)?
        .as_consumer(&tcp_listener_options.spawner_flow_control_id());

    node.flow_controls().add_consumer(
        DefaultAddress::ECHO_SERVICE,
        &sc_listener_options.spawner_flow_control_id(),
    );
    let allow_production = AbacAccessControl::create(node.identities_attributes(), issuer, "cluster", "production");
    node.start_worker_with_access_control(DefaultAddress::ECHO_SERVICE, Echoer, allow_production, AllowAll)
        .await?;

    // Start a secure channel listener that only allows channels with
    // authenticated identities.
    node.create_secure_channel_listener(&server, DefaultAddress::SECURE_CHANNEL_LISTENER, sc_listener_options)
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
use ockam::identity::{SecureChannelOptions, Vault};
use ockam::vault::{EdDSACurve25519SecretKey, SigningSecret, SoftwareVaultForSigning};
use ockam::{route, Context, Result, TcpConnectionOptions};
use ockam::{Node, TcpTransportExtension};
use ockam_api::enroll::enrollment::Enrollment;
use ockam_api::nodes::NodeManager;
use ockam_api::DefaultAddress;
use ockam_multiaddr::MultiAddr;

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    let identity_vault = SoftwareVaultForSigning::create().await?;
    // Import the signing secret key to the Vault
    let secret = identity_vault
        .import_key(SigningSecret::EdDSACurve25519(EdDSACurve25519SecretKey::new(
            hex::decode("31FF4E1CD55F17735A633FBAB4B838CF88D1252D164735CB3185A6E315438C2C")
                .unwrap()
                .try_into()
                .unwrap(),
        )))
        .await?;

    // Create a default Vault but use the signing vault with our secret in it
    let mut vault = Vault::create().await?;
    vault.identity_vault = identity_vault;

    let mut node = Node::builder().await?.with_vault(vault).build(&ctx).await?;
    // Initialize the TCP Transport
    let tcp = node.create_tcp_transport().await?;

    // Create an Identity representing the client
    // We preload the client vault with a change history and secret key corresponding to the identity identifier
    // Ie70dc5545d64724880257acb32b8851e7dd1dd57076838991bc343165df71bfe
    // which is an identifier known to the credential issuer, with some preset attributes
    //
    // We're hard coding this specific identity because its public identifier is known
    // to the credential issuer as a member of the production cluster.
    let change_history = hex::decode("81825837830101583285f68200815820530d1c2e9822433b679a66a60b9c2ed47c370cd0ce51cbe1a7ad847b5835a963f41a654cf98e1a7818fc8e820081584085054457d079a67778f235a90fa1b926d676bad4b1063cec3c1b869950beb01d22f930591897f761c2247938ce1d8871119488db35fb362727748407885a1608").unwrap();
    let client = node.import_private_identity(None, &change_history, &secret).await?;
    println!("issuer identifier {}", client);

    // Connect to the authority node and ask that node to create a
    // credential for the client.
    let issuer_identity = "81825837830101583285f68200815820afbca9cf5d440147450f9f0d0a038a337b3fe5c17086163f2c54509558b62ef4f41a654cf97d1a7818fc7d8200815840650c4c939b96142546559aed99c52b64aa8a2f7b242b46534f7f8d0c5cc083d2c97210b93e9bca990e9cb9301acc2b634ffb80be314025f9adc870713e6fde0d";
    let issuer = node.import_identity_hex(None, issuer_identity).await?;

    // The authority node already knows the public identifier of the client
    // as a member of the production cluster so it returns a signed credential
    // attesting to that knowledge.
    let authority_node = NodeManager::authority_node_client(
        &tcp,
        node.secure_channels().clone(),
        &issuer,
        &MultiAddr::try_from("/dnsaddr/localhost/tcp/5000/secure/api")?,
        &client,
    )
    .await?;
    let credential = authority_node.issue_credential(node.context()).await.unwrap();

    // Verify that the received credential has indeed be signed by the issuer.
    // The issuer identity must be provided out-of-band from a trusted source
    // and match the identity used to start the issuer node
    node.credentials()
        .credentials_verification()
        .verify_credential(Some(&client), &[issuer.clone()], &credential)
        .await?;

    // Create a secure channel to the node that is running the Echoer service.
    let server_connection = tcp.connect("127.0.0.1:4000", TcpConnectionOptions::new()).await?;
    let channel = node
        .create_secure_channel(
            &client,
            route![server_connection, DefaultAddress::SECURE_CHANNEL_LISTENER],
            SecureChannelOptions::new()
                .with_authority(issuer.clone())
                .with_credential(credential)?,
        )
        .await?;

    // Send a message to the worker at address "echoer".
    // Wait to receive a reply and print it.
    let reply = node
        .send_and_receive::<String>(
            route![channel, DefaultAddress::ECHO_SERVICE],
            "Hello Ockam!".to_string(),
        )
        .await?;
    println!("Received: {}", reply); // should print "Hello Ockam!"

    node.stop().await
}

```
{% endcode %}

```
cargo run --example 06-credential-exchange-client
```
