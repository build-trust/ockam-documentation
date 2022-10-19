# Build Secure-by-Design Applications

We've built Ockam with **all** builders in mind and have two different configurations to choose from:

Ockam Open Source can be used for small scale personal projects where manual configuration and simple architectures fit the bill.

Ockam Orchestrator should be used in a company setting. Orchestrator has all of the features that you'll need to collaborate with your team, integrate with automated infrastructure, and serve massive scale throughput.

### Ockam Open Source

Ockam Open Source tools and programming libraries enable applications to:

* Safely Generate, Store, Rotate and Revoke **Cryptographic Keys.**
* Generate unique cryptographically provable **Identities** and manage private keys in safe **Vaults.**
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
* Download from Github.

#### <mark style="background-color:yellow;"></mark>[<mark style="background-color:yellow;">Get Started with Ockam Open Source</mark>](get-started/)<mark style="background-color:yellow;"></mark>

### Ockam Orchestrator

Ockam Orchestrator is a managed cloud service that enables team and companies to:

* Operate highly secure and scalable **Managed Credential Authorities**.
* Enable **Vault Add-Ons**&#x20;
* Provision **Managed Rotation Endpoints** to implement application fleet wide credential rotation and revocation. Issue, Rotate, Revoke least-privileged, short-lived credentials.
* Provision **Managed Enrollment Endpoints** to easily issue fine-grained attribute-based credentials to fleets of application identities using a variety of secure enrollment protocols.
* Enable **Identity Provider Add-Ons** to integrate with enterprise workforce identity and customer identity systems like Okta, Auth0, AzureAD etc. and issue fine-grained, short-lived, just-in-time Ockam credentials to enterprise identities.
* Define, distribute and enforce application fleet-wide **Attribute Based Access Control (ABAC)** policies. Chose your authorization model: ABAC, RBAC or ACLs.
* Enable **Policy Provider Add-Ons** to integrate with enterprise policies.
* Provision **Managed Policy Decision Points** to create one place for all authorization decisions.
* Provision highly scalable and reliable **Managed Encrypted** **Relays** for end-to-end encrypted, high-throughput, low latency communication within applications that are distributed across many edge, cloud and data-center private networks.
* Provision **Managed Rendezvous** to facilitate UDP based NAT traversal.
* Enable **Stream Add-Ons** to bring end-to-end encryption to enterprise messaging and event stream systems like Kafka, RabbitMQ, Kinesis etc.
* Enterprise Support.
* Buy on the AWS Marketplace.

[<mark style="background-color:yellow;">Get Started with Ockam Orchestrator</mark>](orchestrator/get-the-ockam-cli.md)<mark style="background-color:yellow;"></mark>
