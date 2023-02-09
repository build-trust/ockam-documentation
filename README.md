---
description: How to Build Trust for Data-in-Motion
---

# Introduction to Ockam

Ockam is a suite of open source tools, programming libraries, and managed cloud services to orchestrate end-to-end encryption, mutual authentication, key management, credential management, and authorization policy enforcement – at massive scale.

Modern applications are distributed and have an unwieldy number of interconnections that must trustfully exchange data. To **trust data-in-motion**, applications need end-to-end guarantees of data authenticity, integrity, and confidentiality. To be **private** and **secure** **by-design**, applications must have granular control over every trust and access decision. Ockam allows you to add these controls and guarantees to any application.

## Use Cases

<table data-view="cards"><thead><tr><th></th><th></th><th data-hidden></th><th data-hidden></th></tr></thead><tbody><tr><td><strong></strong><a href="use-cases/secure-database-access.md"><strong>Secure database access</strong></a><strong></strong></td><td>Create secure communication with a private database from anywhere</td><td></td><td></td></tr><tr><td><strong></strong><a href="use-cases/secure-database-access.md"><strong>Secure database access</strong></a><strong></strong></td><td>Create secure communication with a private database from anywhere</td><td></td><td></td></tr><tr><td><strong></strong><a href="use-cases/secure-database-access.md"><strong>Secure database access</strong></a><strong></strong></td><td>Create secure communication with a private database from anywhere</td><td></td><td></td></tr></tbody></table>

## Quick Start

Let's build a quick solution for a very common secure communication topology that applies to many real world use cases.

An application service and an application client running in two private networks wish to communicate with each other without exposing ports on the Internet. In a few simple commands, we’ll make them talk to each other through an End-to-End Encrypted Cloud Relay.

First, install Ockam Command and then follow these instructions:&#x20;

### Install Ockam Command

Ockam Command is our Command Line Interface (CLI) for interfacing with Ockam processes.&#x20;

{% tabs %}
{% tab title="Homebrew" %}
If you use Homebrew, you can install Ockam using brew:

```
brew install build-trust/ockam/ockam
```
{% endtab %}

{% tab title="Other Systems" %}

{% endtab %}
{% endtabs %}

```sh
# Install Ockam Command using Homebrew
brew install build-trust/ockam/ockam

# Check that everything was installed by enrolling with Ockam Orchestrator.
#
# This will provision an End-to-End Encrypted Cloud Relay service for you in
# your `default` project at `/project/default`. 
ockam enroll

# -- APPLICATION SERVICE --

# Start an application service, listening on a local ip and port, that clients
# would access through the cloud encrypted relay. We'll use a simple http server
# for this first example but this could be any other application service.
python3 -m http.server --bind 127.0.0.1 5000

# In a new terminal window:
# Setup an ockam node, called `s`, as a sidecar next to the application service.
# Create a tcp outlet, on the `s` node, to send raw tcp traffic to the service.
# Then create a forwarder in your default Orchestrator project.
ockam node create s
ockam tcp-outlet create --at /node/s --from /service/outlet --to 127.0.0.1:5000
ockam forwarder create s --at /project/default --to /node/s

# -- APPLICATION CLIENT --

# Setup an ockam node, called `c`, as a sidecar next to our application client.
# Create an end-to-end encrypted secure channel with s, through the cloud relay.
# Then tunnel traffic from a local tcp inlet through this end-to-end secure channel.
ockam node create c
ockam secure-channel create --from /node/c --to /project/default/service/forward_to_s/service/api \
  | ockam tcp-inlet create --at /node/c --from 127.0.0.1:7000 --to -/service/outlet

# Access the application service, that may be in a remote private network
# though the end-to-end encrypted secure channel, via your cloud relay.
curl --head 127.0.0.1:7000
```

#### Powerful Protocols, Made Simple

To be private and secure by design, applications must have granular control over every trust and access decision. This requires a variety of complex cryptographic and messaging protocols to work together in a secure and scalable way.

Developers have to think about creating unique cryptographic keys and issuing credentials to all application entities. They have to design ways to safely store secrets in hardware and securely distribute roots of trust. They must setup communication channels that guarantee data authenticity and integrity. They must enforce authorization policies. They also need protocols that rotate and revoke credentials.

We handle all of this for you and give you simple tools to:

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

## Learn more

<table data-view="cards"><thead><tr><th></th><th></th><th data-hidden></th></tr></thead><tbody><tr><td><strong></strong><a href="command/"><strong>Ockam Command</strong></a><strong></strong></td><td></td><td></td></tr><tr><td><strong></strong><a href="libraries/rust/"><strong>Ockam Rust Crates</strong></a><strong></strong></td><td></td><td></td></tr><tr><td><strong></strong><a href="manuals/command/ockam-orchestrator.md"><strong>Ockam Orchestrator</strong></a><strong></strong></td><td></td><td></td></tr></tbody></table>

## **Get help**

We are here to help you build with Ockam. If you need help, **** [**please reach out to us**](https://www.ockam.io/contact)!
