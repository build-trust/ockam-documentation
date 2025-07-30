---
description: >-
  Generate cryptographically provable unique identities and store their secret
  keys in safe vaults.
---

# Vaults and Identities

```rust
// examples/vault-and-identities.rs
use ockam::node;
use ockam::{Context, Result};

#[ockam::node]
async fn main(ctx: Context) -> Result<()> {
    // Create default node to safely store secret keys for Alice
    let mut node = node(ctx).await?;

    // Create an Identity to represent Alice.
    let _alice = node.create_identity().await?;

    // Stop the node.
    node.shutdown().await
}

```
