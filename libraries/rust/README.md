---
description: A step-by-step guide
---

# Ockam Rust Crates

In this step-by-step guide we will write many small rust programs to understand the various building blocks that make up Ockam. We’ll dive into Node, Workers, Routing, Transport, Secure Channels and more.

## Get Started

If you don't have it, please [install](https://www.rust-lang.org/tools/install) the latest version of Rust.

```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Next, create a new cargo project to get started

```
cargo new --lib hello_ockam && cd hello_ockam && mkdir examples \
  && cargo add ockam && cargo build
```

If the above instructions don't work on your machine, please [post a question](https://github.com/build-trust/ockam/discussions), we’d love to help.
