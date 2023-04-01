---
description: >-
  Ockam Identities are unique, cryptographically verifiable digital identities.
  Ockam Vaults allow you to safely store and use cryptographic keys for these
  identities.
---

# Identities and Vaults

```shell-session
» ockam vault create v1
Vault created: v1
```

```shell-session
» ockam identity create i1 --vault v1
Identity created: P5f46c9237868938b095288906dd097a1c50d210c4570f2fcd758a417912505e7
```

```
» ockam identity show i1 --full
Change History:
  Change[0]:
    identifier: de95612d88336fabbaae30aabf3a87aab0894530bf8cdc062f93019afa9cc853
    change:
      prev_change_identifier: 0547c93239ba3d818ec26c9cdadd2a35cbdf1fa3b6d1a731e06164b1079fb7b8
      label:        OCKAM_RK
      public_key:   Ed25519 18988c6c1a0ca69d55dbc80f10e012e6c8fbccda6c5c4f893ba5697c6e7e4a51
    signatures:
      [0]: SelfSign 6e71e60050abbc00517fe9cd4aa77fcb30e30e7bc11aa63abe1f570b93672db03c98650bb5843d77d440b23d67636ed2e419205669ecbc83c727083ae6f3eb09
```

