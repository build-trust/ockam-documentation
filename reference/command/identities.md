---
description: >-
  Ockam Identities are unique, cryptographically verifiable digital identities.
  These identities authenticate by proving possession of secret keys. Ockam
  Vaults safely store these secret keys.
---

# Identities and Vaults

In order to make decisions about trust, we must authenticate senders of messages.

## Vault

Ockam [Identities](identities.md#identity) authenticate by cryptographically proving possession of specific secret keys.  Ockam Vaults safely store these secret keys. You can create a vault as follows:&#x20;

```
» ockam vault create v1
Vault created: v1
```

This command will, by default create a file system based vault, where your secret keys are stored at a specific file path. There is a growing base of Ockam Vault implementations in the [<mark style="color:blue;">Ockam Github Repository</mark>](https://github.com/build-trust/ockam) that safely store secret keys in specific KMSs, HSMs, Secure Enclaves etc.

## Identity

Ockam Identities are lightweight, unique, cryptographically verifiable digital identities. You can create any number of identities, by typing: &#x20;

```
» ockam identity create i1 --vault v1
Identity created: Pf87c30a63cd56b4848ed0aa17d582db67fe143279b37e6af1eb460f020685f41
```



### Change History

```
» ockam identity show i1 --full
Change History:
  Change[0]:
    identifier: 5291036cb4d1bfcfb16e4dbc66379eace59598be8500aaf5aca80454cb7b83c4
    change:
      prev_change_identifier: 0547c93239ba3d818ec26c9cdadd2a35cbdf1fa3b6d1a731e06164b1079fb7b8
      label:        OCKAM_RK
      public_key:   Ed25519 d7ea55504402126fac0df91c64abd7838da9add21e9c8a5ee9687c861620b6e5
    signatures:
      [0]: SelfSign c9733663024bcb0ef0cc8e8989d25d459f8dc76881efb7d153b89bd555170c96acf5a4228f710fb4ad28caf6bdfdc3aaafc93bfabeb0b558f9a802aeafdcf407
```

### Identifier Authentication

Authentication, within Ockam, starts by proving control of a specific Ockam Identifier.



#### Recap

{% hint style="info" %}
If you’re stuck or have questions at any point, [<mark style="color:blue;">please reach out to us</mark>](https://www.ockam.io/contact)<mark style="color:blue;">**.**</mark>
{% endhint %}

Next, let's learn how to mutually authenticated and end-to-end encrypted [<mark style="color:blue;">secure channels</mark>](secure-channels.md) that guarantee data authenticity, integrity, and confidentiality.
