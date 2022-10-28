---
description: How to Build Trust for Data-in-Motion
---

# Introduction to Ockam

Ockam is a suite of open source tools, programming libraries, and managed cloud services to orchestrate end-to-end encryption, mutual authentication, key management, credential management, and authorization policy enforcement – at massive scale.

Modern applications are distributed and have an unwieldy number of interconnections that must trustfully exchange data. To **trust data-in-motion**, applications need end-to-end guarantees of data authenticity, integrity, and confidentiality. To be **private** and **secure** **by-design**, applications must have granular control over every trust and access decision. Ockam allows you to add these controls and guarantees to any application.

We are passionate about making powerful cryptographic and messaging protocols **simple and safe to use** for millions of builders. For example, to create a mutually authenticated and end-to-end encrypted secure channel between two Ockam nodes, all you have to do is:

```shell-session
$ ockam secure-channel create --from /node/n1 --to /node/n2/service/api \
    | ockam message send hello --from /node/n1 --to -/service/uppercase

HELLO
```

We handle all the underlying protocol complexity and provide secure, scalable, and reliable building blocks for your applications. In the snippet above we used Ockam Command, it's also just as easy to establish secure channels within your application code using our [Rust Library](https://github.com/build-trust/ockam#next-steps-with-the-rust-library).

Ockam empowers you to:

* Create end-to-end encrypted, authenticated **Secure Channels** over any transport topology.
* Provision **Encrypted** **Relays** for trustful communication within applications that are distributed across many edge, cloud and data-center private networks.
* Tunnel legacy protocols through mutually authenticated and encrypted **Portals.**
* Add-ons to bring end-to-end encryption to enterprise messaging, pub/sub and event streams.
* Generate unique cryptographically provable **Identities** and store private keys in safe **Vaults.** Add-ons for hardware or cloud key management systems.
* Operate project specific and scalable **Credential Authorities** to issue lightweight, short-lived, easy to revoke, attribute-based credentials.
* Onboard fleets of self-sovereign application identities using **Secure Enrollment Protocols** to issue credentials to application clients and services.
* **Rotate** and **revoke** keys and credentials – at scale, across fleets.
* Define and enforce project-wide **Attribute Based Access Control** (ABAC) policies.
* Add-ons to integrate with enterprise **Identity Providers** and **Policy Providers**.

## **Support**

We just launched this docs site in the past week. Updates will come fast and furious.

In the meantime we are here to help you build with Ockam. If you need help, please start a Discussion in GitHub and our team will help you.

****[**Start a Discussion here**](https://github.com/build-trust/ockam/discussions/categories/support)****
