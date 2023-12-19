---
description: Build secure-by-design applications that can trust all data-in-motion.
---

# Introduction to Ockam

Ockam is a suite of programming libraries, command line tools, and managed cloud services to orchestrate end-to-end encryption, mutual authentication, key management, credential management, and authorization policy enforcement – at massive scale.

Modern applications are distributed and have an unwieldy number of interconnections that must trustfully exchange data. To [<mark style="color:blue;">trust data-in-motion</mark>](./#trust-for-data-in-motion), applications need end-to-end guarantees of data authenticity, integrity, and confidentiality. To be [<mark style="color:blue;">private</mark>](./#private-and-secure-by-design) and [<mark style="color:blue;">secure-by-design</mark>](./#private-and-secure-by-design), applications must have granular control over every trust and access decision. Ockam allows you to add these controls and guarantees to any application.

### Use Cases

<table data-view="cards"><thead><tr><th></th><th></th><th data-hidden></th><th data-hidden></th><th data-hidden data-card-target data-type="content-ref"></th></tr></thead><tbody><tr><td><a href="guides/use-cases/#virtually-adjacent-databases"><strong>Virtually-adjacent databases</strong></a></td><td>Create secure communication with private databases, from anywhere. No longer do you need to expose your data to the public internet with service ports.</td><td></td><td></td><td><a href="guides/use-cases/">use-cases</a></td></tr><tr><td><a href="guides/use-cases/#secure-by-design-messaging"><strong>Secure-by-design messaging</strong></a></td><td>Guarantee data authenticity and integrity of events from producers all-the-way to end consumers. End-to-end encrypt data-in-motion through Kafka.</td><td></td><td></td><td><a href="guides/use-cases/">use-cases</a></td></tr><tr><td><a href="guides/use-cases/#developer-first-authorization"><strong>Developer-first authentication</strong></a></td><td>Authenticate and authorize every access decision. Easily add fine-grained, identity-driven controls to enforce enterprise policies everywhere.</td><td></td><td></td><td><a href="guides/use-cases/">use-cases</a></td></tr></tbody></table>

### Quick Start

Let's build a solution for a very common secure communication topology that applies to many real world use cases.

An application service and an application client running in two private networks wish to securely communicate with each other without exposing ports on the Internet. In a few simple commands, we’ll make them safely talk to each other through an End-to-End Encrypted Cloud Relay.

#### Install Ockam Command <a href="#install" id="install"></a>

First, let’s install Ockam Command. Ockam Command is our Command Line Interface (CLI) to build and orchestrate secure distributed applications using Ockam.

{% tabs %}
{% tab title="Homebrew" %}
If you use Homebrew, you can install Ockam using brew.

```sh
# Tap and install Ockam Command
brew install build-trust/ockam/ockam
```

This will download a precompiled binary and add it to your path. If you don’t use Homebrew, you can also install on Linux and MacOS systems using curl. See instructions for other systems in the next tab.
{% endtab %}

{% tab title="Other Systems" %}
On Linux and MacOS, you can download precompiled binaries for your architecture using curl.

```shell
curl --proto '=https' --tlsv1.2 -sSfL https://install.command.ockam.io | bash
```

This will download a precompiled binary and add it to your path. If the above instructions don't work on your machine, please [post a question](https://github.com/build-trust/ockam/discussions), we’d love to help.
{% endtab %}
{% endtabs %}

#### End-to-end encrypted and mutually authenticated communication

Next, step through the following commands to set up secure and private communication between an application service and an application client.

{% tabs %}
{% tab title="Run on your machine" %}
```bash
# Check that everything was installed correctly by enrolling with Ockam Orchestrator.
#
# This will create a Space and Project for you in Ockam Orchestrator and provision an
# End-to-End Encrypted Relay in your `default` project at `/project/default`.
ockam enroll

# -- APPLICATION SERVICE --

# Start an application service, listening on a local IP and port, that clients would access
# through the cloud encrypted relay. We'll use a simple HTTP server for this first example
# but this could be any other application service.
python3 -m http.server --bind 127.0.0.1 6000

# In a new terminal window, setup a tcp-outlet that makes a TCP service available at the given
# address `6000`. We can use this to send raw TCP traffic to the HTTP server on port `6000`.
# Finally create a relay in your default Orchestrator project. Relays make it possible to
# establish end-to-end protocols with services operating in remote private networks, without
# requiring a remote service to expose listening ports to an outside hostile network like the
# Internet.
ockam tcp-outlet create --to 6000
ockam relay create

# -- APPLICATION CLIENT --

# Setup a local tcp-inlet to allow raw TCP traffic to be received on port `7000` before
# it is forwarded. A TCP inlet is a way of defining where a node should be listening for
# connections, and where it should forward that traffic to.
ockam tcp-inlet create --from 7000

# Access the application service, that may be in a remote private network though
# the end-to-end encrypted secure channel, via your private and encrypted cloud relay.
curl --head 127.0.0.1:7000

```
{% endtab %}
{% endtabs %}

### Design Concepts

#### Private and secure by design

In the example above, we’ve created two nodes and established an end-to-end secure channel between them through an encrypted cloud relay. For the sake of simplicity, we ran both ends on a single machine but they could also be run on completely separate machines with the same result: an end-to-end encrypted and mutually authenticated secure channel.

Distributed applications that are connected in this way can communicate without the risk of spoofing, tampering, or eavesdropping attacks irrespective of transport protocols, communication topologies, and network configuration. As application data flows _across data centers, through queues and caches, via gateways and brokers -_ these intermediaries, like the cloud relay in the above example, can facilitate communication but cannot eavesdrop or tamper data.

You can establish secure channels across networks and clouds over multi-hop, multi-protocol routes to build private and [<mark style="color:blue;">secure by design</mark>](introduction/secure-by-design.md) distributed applications that have a small vulnerability surface and full control over data authenticity, integrity, and confidentiality.

#### Trust for data-in-motion

Behind the scenes, the above commands generated unique cryptographically provable identities and saved corresponding keys in a vault. Your orchestrator project was provisioned with a managed credential authority and every node was setup to anchor trust in credentials issued by this authority. Identities were issued project membership credentials and these cryptographically verifiable credentials were then combined with attribute based access control policies to setup a mutually authenticated and authorized end-to-end secure channel.

Your applications can make granular access control decisions at every request because they can be certain about the source and integrity of all data and instructions. You place [<mark style="color:blue;">zero implicit trust</mark>](introduction/secure-by-design.md#zero-implicit-trust) in network boundaries and intermediaries to build applications that have end-to-end application layer trust for all data in motion.

#### Powerful protocols, made simple

Underlying all of this is a variety of cryptographic and messaging protocols. We’ve made these protocols safe and easy to use in any application.

No more having to design error-prone ad-hoc ways to distribute sensitive credentials and roots of trust. Ockam’s integrated approach takes away this complexity and gives you simple tools.

### Features of Ockam

#### End-to-end data authenticity, integrity, and privacy in any communication topology

* Create end-to-end encrypted, authenticated [<mark style="color:blue;">secure channels</mark>](reference/command/secure-channels.md) over any transport topology.
* Create secure channels over [<mark style="color:blue;">multi-hop, multi-protocol routes</mark>](reference/command/routing.md) - TCP, UDP, WebSockets, BLE, etc.
* Provision [<mark style="color:blue;">encrypted relays</mark>](reference/command/secure-channels.md#relays) for applications distributed across many edge, cloud and data-center private networks.
* Make any protocol secure by tunneling it through mutually authenticated and encrypted [<mark style="color:blue;">portals</mark>](reference/command/secure-channels.md#secure-portals).
* Bring end-to-end encryption to enterprise messaging, pub/sub and event streams - Kafka, Kinesis, RabbitMQ etc.

#### Identity-based, policy driven, application layer trust – granular authentication and authorization

* Generate cryptographically provable unique [<mark style="color:blue;">identities</mark>](reference/command/identities.md).
* Store private keys in safe [<mark style="color:blue;">vaults</mark>](reference/command/identities.md) - hardware secure enclaves and cloud key management systems.
* Operate scalable credential authorities to issue lightweight, short-lived, revokable, attribute-based credentials.
* Onboard fleets of self-sovereign application identities using secure enrollment protocols.
* Rotate and revoke keys and credentials – at scale, across fleets.
* Define and enforce project-wide attribute based access control policies - ABAC, RBAC or ACLs.
* Integrate with enterprise identity providers and policy providers for seamless employee access.

### Deep Dives

[<mark style="color:blue;">Read more</mark>](guides/use-cases/) about how teams are using Ockam for many [<mark style="color:blue;">use cases</mark>](guides/use-cases/) across industries or dive into our step-by-step reference on our [<mark style="color:blue;">command line</mark>](reference/command/) and [<mark style="color:blue;">rust libraries</mark>](reference/libraries/).

<table data-card-size="large" data-view="cards"><thead><tr><th></th><th></th><th data-hidden></th><th data-hidden data-card-target data-type="content-ref"></th></tr></thead><tbody><tr><td><a href="reference/command/"><strong>Ockam Command</strong></a></td><td>Command line tools to build and orchestrate highly scalable and secure distributed applications. Orchestrate nodes, vaults, identities, credentials, secure channels, relays, portals and more.</td><td></td><td><a href="reference/command/">command</a></td></tr><tr><td><a href="reference/libraries/"><strong>Ockam Programming Libraries</strong></a></td><td>Rust crates to build secure by design applications for any environment – from highly scalable cloud infrastructure to tiny battery operated microcontroller based devices.</td><td></td><td><a href="reference/libraries/rust/">rust</a></td></tr></tbody></table>

### **Get help**

We are here to help you build with Ockam. If you need help, [<mark style="color:blue;">**please reach out to us**</mark>](https://www.ockam.io/contact)!
