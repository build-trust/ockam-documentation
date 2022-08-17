---
description: Application Layer Routing
---

# Routing

Ockam Routing is an application layer routing protocol that provides the ability to route messages between [workers](workers.md) within a [node](nodes.md) or across nodes using [transports](transports/).

Messages can be sent over multiple hops, within one node or across many nodes.

In our example below, messages are being sent from the source, Node n1 to Node n2 and then the final destination, Node n3.

```bash
# Create three Ockam nodes n1, n2 & n3
> for i in {1..3}; do ockam node create "n$i" --tcp-listener-address "127.0.0.1:600$i"; done

# Route a message 
> ockam message send "hello" --from n1 \
    --to /ip4/127.0.0.1/tcp/6002/ip4/127.0.0.1/tcp/6003/service/uppercase
HELLO

```

```bash
# Create three Ockam nodes n1, n2 & n3
> for i in {1..3}; do ockam node create "n$i"; done

# Route a message
> ockam message send "hello" --from n1 --to /node/n2/node/n3/service/uppercase
HELLO
```
