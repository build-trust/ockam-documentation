---
description: >-
  Rust crates to build secure by design applications for any environment – from
  highly scalable cloud infrastructure to tiny battery operated microcontroller
  based devices.
---

# Rust

Ockam Rust crates are a library of tools to build secure by design applications for any environment – from highly scalable cloud infrastructure to tiny battery operated microcontroller based devices. They make it easy to orchestrate end-to-end encryption, mutual authentication, key management, credential management, and authorization policy enforcement – at massive scale.

No more having to think about creating unique cryptographic keys and issuing credentials to your fleet of application entities. No more designing ways to safely store secrets in hardware and securely distribute roots of trust.

#### <mark style="color:orange;">End-to-end data authenticity, integrity, and privacy in any communication topology</mark>

* Create end-to-end encrypted, authenticated secure channels over any transport topology.
* Create secure channels over multi-hop, multi-protocol routes over TCP, UDP, WebSockets, BLE, etc.
* Provision encrypted relays for applications distributed across many edge, cloud and data-center private networks.
* Make legacy protocols secure by tunneling them through mutually authenticated and encrypted portals.
* Bring end-to-end encryption to enterprise messaging, pub/sub and event streams - Kafka, Kinesis, RabbitMQ etc.

#### <mark style="color:orange;">Identity-based, policy driven, application layer trust – granular authentication and authorization</mark>

* Generate cryptographically provable unique identities.
* Store private keys in safe vaults - hardware secure enclaves and cloud key management systems.
* Operate scalable credential authorities to issue lightweight, short-lived, revokable, attribute-based credentials.
* Onboard fleets of self-sovereign application identities using secure enrollment protocols.
* Rotate and revoke keys and credentials – at scale, across fleets.
* Define and enforce project-wide attribute based access control policies. Chose ABAC, RBAC or ACLs.
* Integrate with enterprise identity providers and policy providers for seamless employee access.

<figure><img src="../../../.gitbook/assets/Screen Shot 2022-10-28 at 10.37.03 AM (1).png" alt=""><figcaption><p>Please click the diagram to see a bigger version.</p></figcaption></figure>

## A step by step introduction <a href="#introduction" id="introduction"></a>

Ockam Rust crates provide the above collection of composable building blocks. In a step-by-step hands-on guide let’s walk through each building block to understand how you can use them to build end-to-end trustful communication for any application in any communication topology.

The first step is to install Rust and create a cargo project called `hello_ockam` We’ll use this project to try out various examples.

{% tabs %}
{% tab title="Get Started" %}
If you don't have it, please [install](https://www.rust-lang.org/tools/install) the latest version of Rust.



```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```



Next, create a new cargo project to get started:

```bash
cargo new --lib hello_ockam && cd hello_ockam && mkdir examples \
  && cargo add ockam && cargo build
```

If the above instructions don't work on your machine, please [post a question](https://github.com/build-trust/ockam/discussions), we’d love to help.
{% endtab %}
{% endtabs %}

