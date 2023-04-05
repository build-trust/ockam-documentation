---
description: >-
  Ockam Identities are unique, cryptographically verifiable digital identities.
  These identities authenticate by proving possession of secret keys. Ockam
  Vaults safely store these secret keys.
---

# Identities and Vaults

An Ockam Identity has an Identifier, Signed Change History, and private keys.

ED25519 or NIST P-256 keys.

```shell-session
» ockam vault create v1
Vault created: v1

» ockam identity create i1 --vault v1
Identity created: Pf87c30a63cd56b4848ed0aa17d582db67fe143279b37e6af1eb460f020685f41
```



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
