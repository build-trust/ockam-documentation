---
description: >-
  Ockam Secure Channels are mutually authenticated and end-to-end encrypted
  messaging channels that guarantee data authenticity, integrity, and
  confidentiality.
---

# Secure Channels

In previous sections we saw how Ockam <mark style="color:blue;">Routing</mark> and <mark style="color:blue;">Transports,</mark> when combined with the ability to model <mark style="color:blue;">Bridges</mark> and <mark style="color:blue;">Relays</mark>, make it possible to <mark style="color:orange;">create end-to-end, application layer protocols in</mark> <mark style="color:orange;"></mark><mark style="color:orange;">**any**</mark> <mark style="color:orange;"></mark><mark style="color:orange;">communication topology</mark> - across networks, clouds, and boundaries.

We also learnt about Ockam <mark style="color:blue;">Identities</mark>. These unique, cryptographically verifiable digital identities authenticate by proving possession of secret keys that are safely stored in Ockam <mark style="color:blue;">Vaults</mark>.

Establishing a secure channel requires establishing a shared secret key between the two entities that wish to communicate securely. This is usually achieved using a cryptographic key agreement protocol to safely derive a shared secret without transporting it over the network.

```
» ockam project information --output json > project.json

» ockam node create n1 --project project.json
» ockam node create n3 --project project.json

» ockam forwarder create n3 --at /project/default --to /node/n3
/service/forward_to_n3

» ockam secure-channel create --from n1 --to /project/default/service/forward_to_n3/service/api \
    | ockam message send hello --from n1 --to -/service/uppercase
HELLO
```



