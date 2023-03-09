---
description: >-
  Generate cryptographically provable unique identities and store their secret
  keys in safe vaults.
---

# Vaults and Identities

```rust
use ockam::{Context, Result};

#[ockam::node]
async fn main(mut ctx: Context) -> Result<()> {
    // Create a Vault to safely store secret keys for Alice.
    let vault = Vault::create();

    // Create an Identity to represent Alice.
    let alice = Identity::create(&ctx, &vault).await?;

    // Stop the node.
    ctx.stop().await
}
```
