---
description: >-
  Generate cryptographically provable unique identities and store their secret
  keys in safe vaults.
---

# Vaults and Identities

```rust
use ockam::{Context, Result};
use ockam::identity::Identity;
use ockam::node;

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    // Create default node to safely store secret keys for Alice
    let mut node = node(ctx);

    // Create an Identity to represent Alice.
    let alice = node.create_identity().await?;

    // Stop the node.
    node.stop().await
}
```
