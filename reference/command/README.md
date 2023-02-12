---
description: >-
  Command line tools to build and orchestrate highly scalable and secure
  distributed applications.
---

# Command

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

<figure><img src="../../.gitbook/assets/Screen Shot 2022-10-28 at 10.37.03 AM.png" alt=""><figcaption><p>Please click the diagram to see a bigger version.</p></figcaption></figure>

