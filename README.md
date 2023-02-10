---
description: How to Build Trust for Data-in-Motion
---

# Introduction to Ockam

Ockam is a suite of open source tools, programming libraries, and managed cloud services to orchestrate end-to-end encryption, mutual authentication, key management, credential management, and authorization policy enforcement – at massive scale.

Modern applications are distributed and have an unwieldy number of interconnections that must trustfully exchange data. To **trust data-in-motion**, applications need end-to-end guarantees of data authenticity, integrity, and confidentiality. To be **private** and **secure** **by-design**, applications must have granular control over every trust and access decision. Ockam allows you to add these controls and guarantees to any application.

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

#### Run Quick Start

```bash
# Check that everything was installed correctly by enrolling with Ockam Orchestrator.
#
# This will create a Space and Project in for you in the Orchestrator and provision an
# End-to-End Encrypted Cloud Relay service for you your `default` project at `/project/default`.
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
# end-to-end encrypted secure channel with s, through the cloud relay. Finally, tunnel traffic from
# a local tcp inlet through this end-to-end secure channel.
ockam node create c --project default-project.json
ockam secure-channel create --from /node/c --to /project/default/service/forward_to_s/service/api\
  | ockam tcp-inlet create --at /node/c --from 127.0.0.1:7000 --to -/service/outlet

# Access the application service, that may be in a remote private network though the end-to-end
# encrypted secure channel, via your private and encrypted cloud relay.
curl --head 127.0.0.1:7000
```

#### Private & secure by design

In the example above we've created two nodes and established a secure channel between them. While the example above is running on a single machine for the sake of simplicity, each node also be running on completely separate devices with same end result: an end-to-end encrypted and authenticated secure channel. Any network configuration, transport topology, or services being connected can now have a secure means of communicating without the risk of eavesdropping or MITM attacks irrespective protocols being used. Privacy has been moved to the communication channel itself, which means _any_ use of that channel is secure by design. The use of Ockam's [programming libraries](manuals/programming-libraries/) pushes that secure channel beyond the network level and embeds it directly into your application or device. Underlying all of this is a variety of complex cryptographic and messaging protocols that work together in a secure and scalable way.

#### Trust for data-in-motion

Not obvious from this example is that each node also has a unique identity, with a set of unique cryptographic keys. Creating a secure tunnel between services can provide privacy, but how do you know who is communicating on the other side of that tunnel? Ockam's approach to provable identities means that secure communication channels also guarantee data authenticity and integrity. With an integrated approach to enforcing authorization policies, and protocols for rotating and revoking credentials.&#x20;

#### Powerful protocols, made simple

No more having to think about creating unique cryptographic keys and issuing credentials to all application entities. No more designing ways to safely store secrets in hardware and securely distribute roots of trust. Ockam takes away this complexity and give you simple tools to:

* Create end-to-end encrypted, authenticated secure channels over any transport topology.
* Provision encrypted relays for trustful communication within applications that are distributed across many edge, cloud and data-center private networks.
* Tunnel legacy protocols through mutually authenticated and encrypted **Portals.**
* Add-ons to bring end-to-end encryption to enterprise messaging, pub/sub and event streams.
* Generate unique cryptographically provable **Identities** and store private keys in safe **Vaults.** Add-ons for hardware or cloud key management systems.
* Operate project specific and scalable **Credential Authorities** to issue lightweight, short-lived, easy to revoke, attribute-based credentials.
* Onboard fleets of self-sovereign application identities using **Secure Enrollment Protocols** to issue credentials to application clients and services.
* **Rotate** and **revoke** keys and credentials – at scale, across fleets.
* Define and enforce project-wide **Attribute Based Access Control** (ABAC) policies.
* Add-ons to integrate with enterprise **Identity Providers** and **Policy Providers**.

## Learn more

<table data-view="cards"><thead><tr><th></th><th></th><th data-hidden></th></tr></thead><tbody><tr><td><strong></strong><a href="broken-reference"><strong>Ockam Command</strong></a><strong></strong></td><td></td><td></td></tr><tr><td><strong></strong><a href="broken-reference"><strong>Ockam Rust Crates</strong></a><strong></strong></td><td></td><td></td></tr></tbody></table>

## **Get help**

We are here to help you build with Ockam. If you need help, **** [**please reach out to us**](https://www.ockam.io/contact)!
