---
description: Command line tools to build and orchestrate secure by design applications.
---

# Command

Ockam Command is our command line interface to build secure by design applications that can trust all data in motion. It makes it easy to orchestrate end-to-end encryption, mutual authentication, key management, credential management, and authorization policy enforcement – at massive scale.

No more having to design error-prone ad-hoc ways to distribute sensitive credentials and roots of trust. Ockam’s integrated approach takes away this complexity and gives you simple tools for:

#### <mark style="color:orange;">End-to-end data authenticity, integrity, and privacy in any communication topology</mark>

* Create end-to-end encrypted, authenticated secure channels over any transport topology.
* Create secure channels over multi-hop, multi-protocol routes over TCP, UDP, WebSockets, BLE, etc.
* Provision encrypted relays for applications distributed across many edge, cloud and data-center private networks.
* Make any protocol secure by tunneling it through mutually authenticated and encrypted portals.
* Bring end-to-end encryption to enterprise messaging, pub/sub and event streams - Kafka, Kinesis, RabbitMQ etc.

#### <mark style="color:orange;">Identity-based, policy driven, application layer trust – granular authentication and authorization</mark>

* Generate cryptographically provable unique identities.
* Store private keys in safe vaults - hardware secure enclaves and cloud key management systems.
* Operate scalable credential authorities to issue lightweight, short-lived, revokable, attribute-based credentials.
* Onboard fleets of self-sovereign application identities using secure enrollment protocols.
* Rotate and revoke keys and credentials – at scale, across fleets.
* Define and enforce project-wide attribute based access control policies. Choose ABAC, RBAC or ACLs.
* Integrate with enterprise identity providers and policy providers for seamless employee access.



<figure><img src="../../.gitbook/assets/Screen Shot 2022-10-28 at 10.37.03 AM (1).png" alt=""><figcaption><p>Please click the diagram to see a bigger version.</p></figcaption></figure>

## A step by step introduction <a href="#introduction" id="introduction"></a>

Ockam Command provides the above collection of composable building blocks that are accessible through various sub commands. In a step-by-step guide let’s walk through various Ockam sub commands to understand how you can use them to build end-to-end trustful communication for any application in any communication topology.

#### Install Ockam Command <a href="#install" id="install"></a>

If you haven't already, the first step is to install Ockam Command:

{% tabs %}
{% tab title="Homebrew" %}
If you use Homebrew, you can install Ockam using brew.



```sh
# Tap and install Ockam Command
brew install build-trust/ockam/ockam
```



This will download a precompiled binary and add it to your path. If you don’t use Homebrew, you can also install on Linux and MacOS systems using curl. See instructions for other systems in the next tab.
{% endtab %}

{% tab title="Other Systems " %}
On Linux and MacOS, you can download precompiled binaries for your architecture using curl.



```shell
curl --proto '=https' --tlsv1.2 -sSf \
    https://raw.githubusercontent.com/build-trust/ockam/develop/install.sh | bash
```



This will download a precompiled binary and add it to your path. If the above instructions don't work on your machine, please [post a question](https://github.com/build-trust/ockam/discussions), we’d love to help.
{% endtab %}
{% endtabs %}

Check that everything was installed correctly by enrolling with Ockam Orchestrator.

```sh
# This will create a Space and Project for you in Ockam Orchestrator and provision
# an End-to-End Encrypted Cloud Relay service in your default project at /project/default.
ockam enroll
```

Next let‘s dive in and learn how to use [<mark style="color:blue;">Nodes and Workers</mark>](nodes.md).
