# Command

<figure><img src="../../.gitbook/assets/Screen Shot 2022-10-28 at 10.37.03 AM.png" alt=""><figcaption><p>Please click the diagram to see a bigger version.</p></figcaption></figure>

Ockam Open Source tools and programming libraries enable applications to:

* Safely Generate, Store, Rotate and Revoke **Cryptographic Keys.**
* Generate unique cryptographically provable **Identifiers** and manage private keys in safe **Vaults.**
* Enable **Vault Add-Ons** for various TEEs, TPMs, HSMs, Secure Enclaves, and Cloud KMSs.
* Create **Credential Authorities** to issue lightweight, fine-grained attribute-based credentials**.**
* Securely Issue, Store, Present, and Verify cryptographically verifiable **Credentials**.
* Define and enforce Attribute Based Access Control (ABAC) **Policies**.
* Deliver messages reliably over any Transport topology using - Application Layer **Routing**.
* Create end-to-end encrypted, mutually authenticated, and authorized **Secure Channels** over multi-hop, multi-protocol **Transport** topologies.
* Enable **Transport Add-Ons** for various protocols TCP, UDP, WebSockets, BLE, LoRaWAN etc.
* Securely traverse NATs and protocol gateways using **** end-to-end encrypted **Relays.**&#x20;
* Tunnel any application protocol through mutually authenticated and encrypted **Portals.**
* Operate in **any environment** - cloud virtual machines or constrained embedded devices.
* Integrate deeply using our **rust** **library** or run as an application **sidecar** process or container.
* Licensed under the Apache 2.0 open source license.&#x20;
* Community Support.

In this step-by-step guide we try various Ockam sub commands to understand the various building blocks that make up Ockam.



Ockam Orchestrator is a managed cloud service that enables team and companies to:

* Operate highly secure and scalable **Managed Credential Authorities**.
* Provision **Managed Rotation Endpoints** to implement application fleet wide credential rotation and revocation. Issue, Rotate, Revoke least-privileged, short-lived credentials.
* Provision **Managed Enrollment Endpoints** to easily issue fine-grained attribute-based credentials to fleets of application identities using a variety of secure enrollment protocols.
* Enable **Identity Provider Add-Ons** to integrate with enterprise workforce identity and customer identity systems like Okta, Auth0, AzureAD etc. and issue fine-grained, short-lived, just-in-time Ockam credentials to enterprise identities.
* Define, distribute and enforce application fleet-wide **Attribute Based Access Control (ABAC)** policies. Chose your authorization model: ABAC, RBAC or ACLs.
* Enable **Policy Provider Add-Ons** to integrate with enterprise policies.
* Provision **Managed Policy Decision Points** to create one place for all authorization decisions.
* Provision highly scalable and reliable **Managed Encrypted** **Relays** for end-to-end encrypted, high-throughput, low latency communication within applications that are distributed across many edge, cloud and data-center private networks.
* Provision **Managed Rendezvous** to facilitate UDP based NAT traversal.
* Enable **Stream Add-Ons** to bring end-to-end encryption to enterprise messaging and event streaming systems like Kafka, RabbitMQ, Kinesis etc.
* Enable **Vault Add-Ons** to safely store keys in cloud key management systems.
* Enterprise Support.

**Commercial support for Ockam Orchestrator is available** [**through the AWS Marketplace**](https://aws.amazon.com/marketplace/pp/prodview-wsd42efzcpsxk)**.**

## Get Started

#### Homebrew

If you use Homebrew, you can install Ockam using `brew`.

```bash
brew install build-trust/ockam/ockam
```

#### Precompiled Binaries

Otherwise, you can download our latest architecture specific pre-compiled binary by running:

```shell
curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/build-trust/ockam/develop/install.sh | sh
```

After the binary downloads, please move it to a location in your shell's `$PATH`, like `/usr/local/bin`.

If the above instructions don't work on your machine, please [post a question](https://github.com/build-trust/ockam/discussions), we’d love to help.
