---
description: How to build secure by design applications that can trust all data in motion.
---

# Introduction to Ockam

Ockam is a suite of open source tools, programming libraries, and managed cloud services to orchestrate end-to-end encryption, mutual authentication, key management, credential management, and authorization policy enforcement – at massive scale.

Modern applications are distributed and have an unwieldy number of interconnections that must trustfully exchange data. To [trust data-in-motion](./#trust-for-data-in-motion), applications need end-to-end guarantees of data authenticity, integrity, and confidentiality. To be [private and secure by-design](./#private-and-secure-by-design), applications must have granular control over every trust and access decision. Ockam allows you to add these controls and guarantees to any application.

## Use Cases

<table data-card-size="large" data-view="cards"><thead><tr><th></th><th></th><th data-hidden></th><th data-hidden></th></tr></thead><tbody><tr><td><strong></strong><a href="guides/use-cases/secure-database-access.md"><strong>Secure database access</strong></a><strong></strong></td><td>Create secure communication with a private database from anywhere.</td><td></td><td></td></tr><tr><td><strong></strong><a href="guides/use-cases/secure-database-access.md"><strong>Connect distributed clients to time series backends</strong></a><strong></strong></td><td>Send messages, metrics, and events from thousands of devices to services such as InfluxDB, without exposing your data store to the internet.</td><td></td><td></td></tr></tbody></table>

## Quick Start

Let's build a quick solution for a very common secure communication topology that applies to many real world use cases.

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
 curl --proto '=https' --tlsv1.2 -sSf \
   https://raw.githubusercontent.com/build-trust/ockam/develop/install.sh | sh
```



After the binary downloads, please move it to a location that is in your shell's `$PATH`, for example `/usr/local/bin`.
{% endtab %}
{% endtabs %}

#### End-to-end encrypted and mutually authenticated communication

Next, step through the following commands to setup secure and private communication between our application service and an application client.

```bash
# Check that everything was installed correctly by enrolling with Ockam Orchestrator.
#
# This will create a Space and Project for you in Ockam Orchestrator and provision an
# End-to-End Encrypted Cloud Relay service in your `default` project at `/project/default`.
ockam enroll
ockam project information --output json > default-project.json

# -- APPLICATION SERVICE --

# Start an application service, listening on a local ip and port, that clients would access
# through the cloud encrypted relay. We'll use a simple http server for this first example but
# this could be any other application service.
python3 -m http.server --bind 127.0.0.1 5000

# In a new terminal window, setup an ockam node, called `s`, as a sidecar next to the 
# application service. Then create a tcp outlet, on the `s` node, to send raw tcp traffic to the
# service. Finally create a forwarder in your default Orchestrator project.
ockam node create s --project default-project.json
ockam tcp-outlet create --at /node/s --from /service/outlet --to 127.0.0.1:5000
ockam forwarder create s --at /project/default --to /node/s

# -- APPLICATION CLIENT --

# Setup an ockam node, called `c`, as a sidecar next to our application client. Then create an
# end-to-end encrypted secure channel with s, through the cloud relay. Finally, tunnel traffic
# from a local tcp inlet through this end-to-end secure channel.
ockam node create c --project default-project.json
ockam secure-channel create --from /node/c --to /project/default/service/forward_to_s/service/api\
  | ockam tcp-inlet create --at /node/c --from 127.0.0.1:7000 --to -/service/outlet

# Access the application service, that may be in a remote private network though the end-to-end
# encrypted secure channel, via your private and encrypted cloud relay.
curl --head 127.0.0.1:7000

```

#### Private and secure by design

In the example above, we’ve created two nodes and established an end-to-end secure channel between them through an encrypted cloud relay. For the sake of simplicity, we ran both ends on a single machine but they could also be run on completely separate machines with the same result: an end-to-end encrypted and mutually authenticated secure channel.

Distributed applications that are connected in this way can communicate without the risk of spoofing, tampering, or eavesdropping attacks irrespective of transport protocols, communication topologies, and network configuration. As application data flows _across data centers, through queues and caches, via gateways and brokers -_ these intermediaries, like the cloud relay in the above example, can facilitate communication but cannot eavesdrop or tamper data.

You can establish secure channels across networks and clouds over multi-hop, multi-protocol routes to build private and [secure by design](readme/secure-by-design.md) distributed applications that have a small vulnerability surface and full control over data authenticity, integrity, and confidentiality.

#### Trust for data-in-motion

Behind the scenes, the above commands generated unique cryptographically provable identities and saved corresponding keys in a vault. Your orchestrator project was provisioned with a managed credential authority and every node was setup to anchor trust in credentials issued by this authority. Identities were issued project membership credentials and these cryptographically verifiable credentials were then combined with attribute based access control policies to setup a mutually authenticated and authorized end-to-end secure channel.

Your applications can make granular access control decisions at every request because they can be certain about the source and integrity of all data and instructions. You place [zero implicit trust](readme/secure-by-design.md#zero-implicit-trust) in network boundaries and intermediaries to build applications that have end-to-end application layer trust for all data in motion.

#### Powerful protocols, made simple

Underlying all of this is a variety of cryptographic and messaging protocols. We’ve made these protocols safe and easy to use in any application.

No more having to think about creating unique cryptographic keys and issuing credentials to all application entities. No more designing ways to safely store secrets in hardware and securely distribute roots of trust. Ockam’s integrated approach takes away this complexity and gives you simple tools for:

<mark style="color:blue;">End-to-end data authenticity, integrity and privacy in any communication topology</mark>

* Create end-to-end encrypted, authenticated secure channels over any transport topology.
* Create secure channels over multi-hop, multi-protocol routes - TCP, UDP, WebSockets, BLE, etc.&#x20;
* Provision encrypted relays for applications distributed across many edge, cloud and data-center private networks.
* Tunnel legacy protocols through mutually authenticated and encrypted portals**.**
* Bring end-to-end encryption to enterprise messaging, pub/sub and event streams - Kafka, Kinesis, RabbitMQ etc.

<mark style="color:blue;">Identity-based, policy driven, application layer trust</mark>

* Generate cryptographically provable unique identities.
* Store private keys in safe vaults - hardware secure enclaves and cloud key management systems.
* Operate scalable credential **** authorities to issue lightweight, short-lived, easy to revoke, attribute-based credentials.
* Onboard fleets of self-sovereign application identities using secure enrollment protocols.
* Rotate **** and **** revoke keys and credentials – at scale, across fleets.
* Define and enforce project-wide attribute based access control policies - ABAC, RBAC or ACLs
* Integrate with enterprise identity providers and policy providers for seamless employee access.

## Deep Dive

<table data-card-size="large" data-view="cards"><thead><tr><th></th><th></th><th data-hidden></th></tr></thead><tbody><tr><td><strong></strong><a href="manuals/command/"><strong>Ockam Command</strong></a><strong></strong></td><td>A command line interface to build and orchestrate highly scalable, secure, and private distributed applications.</td><td></td></tr><tr><td><strong></strong><a href="manuals/programming-libraries/"><strong>Ockam Programming Libraries</strong></a><strong></strong></td><td>Rust crates to integrate</td><td></td></tr></tbody></table>

## **Get help**

We are here to help you build with Ockam. If you need help, **** [**please reach out to us**](https://www.ockam.io/contact)!
