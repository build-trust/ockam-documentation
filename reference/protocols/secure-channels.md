---
description: >-
  Ockam Secure Channels are mutually authenticated and end-to-end encrypted
  messaging channels that guarantee data authenticity, integrity, and
  confidentiality.
---

# Secure Channels

Ockam Secure Channels is an end-to-end protocol built on top of <mark style="color:blue;">Ockam Routing</mark>.&#x20;

This cryptographic protocol allows two applications to exchange messages in a way that is designed to prevent message forgery, tampering, and eavesdropping.

<figure><img src="../../.gitbook/assets/xx.png" alt=""><figcaption></figcaption></figure>

## Primitives

* Curve25519
* ECDH
* SHA256
* HKDF
* AEAD\_AES\_128\_GCM
