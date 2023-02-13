---
description: >-
  Command line tools to build and orchestrate highly secure distributed
  applications.
---

# Command

Ockam Command is our Command Line Interface (CLI) to build secure distributed applications.

#### End-to-end data authenticity, integrity, and privacy in any communication topology

* Create end-to-end encrypted, authenticated secure channels over any transport topology.
* Create secure channels over multi-hop, multi-protocol routes - TCP, UDP, WebSockets, BLE, etc.
* Provision encrypted relays for applications distributed across many edge, cloud and data-center private networks.
* Make legacy protocols secure by tunneling them through mutually authenticated and encrypted portals.
* Bring end-to-end encryption to enterprise messaging, pub/sub and event streams - Kafka, Kinesis, RabbitMQ etc.

#### Identity-based, policy driven, application layer trust – granular authentication and authorization

* Generate cryptographically provable unique identities.
* Store private keys in safe vaults - hardware secure enclaves and cloud key management systems.
* Operate scalable credential authorities to issue lightweight, short-lived, revokable, attribute-based credentials.
* Onboard fleets of self-sovereign application identities using secure enrollment protocols.
* Rotate and revoke keys and credentials – at scale, across fleets.
* Define and enforce project-wide attribute based access control policies - ABAC, RBAC or ACLs.
* Integrate with enterprise identity providers and policy providers for seamless employee access.

<figure><img src="../../.gitbook/assets/Screen Shot 2022-10-28 at 10.37.03 AM.png" alt=""><figcaption><p>Please click the diagram to see a bigger version.</p></figcaption></figure>

## A step by step introduction

In this step-by-step guide we try various Ockam sub commands to understand the various building blocks that make up Ockam.

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
    https://raw.githubusercontent.com/build-trust/ockam/develop/install.sh | sh
```



After the binary downloads, please move it to a location that is in your shell's `$PATH`.

```bash
mv ockam /usr/local/bin
```
{% endtab %}
{% endtabs %}
