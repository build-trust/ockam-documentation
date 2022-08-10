---
description: Trust for Data-in-Motion
---

# What is Ockam?

Ockam is a suite of **open source** tools, programming libraries and cloud services to orchestrate end-to-end encryption, mutual authentication, key management, credential management & authorization policy enforcement — at scale.

Modern applications are distributed and have an unwieldy number of interconnections that must trustfully exchange data.

In order to trust information or instructions, that are received over the network, applications must **authenticate** all senders and **verify the integrity of data** **received** to assert what was received is exactly what was sent — free from errors or en-route tampering.

Application layer communication is also usually bi-directional since, at the very least, we have to acknowledge receipt of data to its senders. This means that authentication and the data integrity guarantee within applications must be **mutual** between any two communicating parts.

Our applications have moved out of data center boundaries into multi-tenant cloud environments,&#x20;





Install Ockam Command using Homebrew

<pre class="language-bash"><code class="lang-bash"><strong>> brew install build-trust/ockam/ockam</strong></code></pre>



```bash
> for i in {1..3}; do ockam node create "n$i"; done
```







```bash
# Install Ockam Command using Homebrew


# Create three Ockam nodes n1, n2 & n3


# Route a message
> ockam message send "hello" --from n1 --to /node/n2/node/n3/service/uppercase
HELLO

# Create a mutually authenticated, authorized, end-to-end encrypted secure channel
# from node n1, via node n2, over two tcp hops to api service on node n3.
#
# Then send an end-to-end encrypted message to the uppercase service on n3,
# using this channel.
# 
# n2 cannot see or tamper the onroute message
> ockam secure-channel create --from n1 --to /node/n2/node/n3/service/api \
    | ockam message send "hello" --from n1 --to -/service/uppercase
HELLO
```
