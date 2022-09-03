# Secure Channels

Secure Channels provide end-to-end encrypted and mutually authenticated communication that is safe against eavesdropping, tampering, and forgery of messages en-route.

To create a secure channel, we first need a secure channel listener. Every node that is started with ockam command by default starts a secure channel listener at the address `/service/api`.

```shell
$ ockam node create n1
$ ockam node create n2
$ ockam secure-channel create --from /node/n1 --to /node/n2/service/api \
    | ockam message send hello --from /node/n1 --to -/service/uppercase
HELLO
```

The Ockam Secure Channels protocol is based on a cryptographic handshake designs proposed in the Noise Protocol Framework.&#x20;

Ockam Secure Channels protocol is layered above Ockam Routing and is decoupled from transport protocols like TCP, UDP, Bluetooth etc. This allows Ockam Secure Channels to be end-to-end over multiple transport layer hops.

For instance we can create a secure channel over two TCP connection hops as follows:

```shell
$ ockam node create n1
$ ockam node create n2
$ ockam node create n3

$ ockam secure-channel create --from /node/n1 --to /node/n2/node/n3/service/api \
    | ockam message send hello --from /node/n1 --to -/service/uppercase
HELLO
```



An Ockam Secure Channel is a protocol that provides a set of guarantees - data integrity, confidentiality and authentication.

An Ockam Secure Channel has an initiator and and a responder which is where is a message is starting from and where it is going to.&#x20;

There are 2 main actions that take place:

1. The initiator and responder run a cryptographic protocol called an Authenticated Key Exchange which authenticates both of them and creates a shared secret that they both agree on.&#x20;
2. Then they use Authenticated Encryption to encrypt all the data that is exchanged between the initiator and responder.

The result is a way for messages to be exchanged in a trustful manner.

```bash
# Create three Ockam nodes n1, n2 & n3
> for i in {1..3}; do ockam node create "n$i"; done

# Create a mutually authenticated, authorized, end-to-end encrypted secure channel
# from node n1, via node n2, over two tcp hops to api service on node n3.
#
# Then send an end-to-end encrypted message to the uppercase service on n3,
# using this channel.
# 
# n2 cannot see or tamper the onroute message
> ockam secure-channel create --from n1 --to /node/n2/node/n3/service/api \
    | ockam message send "hello ockam!" --from n1 --to -/service/uppercase
HELLO OCKAM
```

Below are examples of how to create secure channels.

#### Create a secure channel between two nodes and send a message through the secure channel:

```bash
> ockam node create n1
> ockam node create n2

> ockam secure-channel create --from /node/n1 --to /node/n2/service/api \
    | ockam message send hello --from /node/n1 --to -/service/uppercase
HELLO
```

#### Create a secure channel with a secure channel listener:

```bash
> ockam node create n1
> ockam node create n2

> ockam secure-channel-listener create "listener" --at /node/n2
> ockam secure-channel create --from /node/n1 --to /node/n2/service/listener \
    | ockam message send hello --from /node/n1 --to -/service/uppercase
HELLO
```



```
Secure Channels provide end-to-end encrypted and mutually authenticated communication
that is safe against eavesdropping, tampering, and forgery of messages en-route.

To create a secure channel, we first need a secure channel listener. Every node that
is started with ockam command, by convention, starts a secure channel listener at the
address /service/api.

So the simplest example of creating a secure channel would be:

$ ockam node create n1
$ ockam node create n1

$ ockam secure-channel create --from /node/n1 --to /node/n2/service/api
/service/09738b73c54b81d48531f659aaa22533

The Ockam Secure Channels protocol is based on handshake designs proposed in the
Noise Protocol Framework. The Noise framework proposes several handshake designs
that make different tradeoffs to achieve various security properties like mutual
authentication, forward secrecy, and resistance to key compromise impersonation etc.
These design have been scrutinized by many experts and have, openly published,
formal proofs.

Ockam Secure Channels protocol is an opinionated implementation of one such proven
design and `ockam` command makes it super simple to create mutually authenticated
noise based secure channels.

This secure channels protocol is layered above Ockam Routing and is decoupled
from transport protocols like TCP, UDP, Bluetooth etc. This allows Ockam Secure Channels
to be end-to-end over multiple transport layer hops.

For instance we can create a secure channel over two TCP connection hops, as follows,
and then send a message through it.

# Create three nodes and make them start tcp transport listeners at specific ports
$ ockam node create n1 --tcp-listener-address 127.0.0.1:6001
$ ockam node create n2 --tcp-listener-address 127.0.0.1:6002
$ ockam node create n3 --tcp-listener-address 127.0.0.1:6003

$ ockam secure-channel create --from /node/n1 \
    --to /ip4/127.0.0.1/tcp/6002/ip4/127.0.0.1/tcp/6003/service/api \
      | ockam message send hello --from /node/n1 --to -/service/uppercase
HELLO

# Or the more concise:
$ ockam secure-channel create --from /node/n1 --to /node/n2/node/n3/service/api \
    | ockam message send hello --from /node/n1 --to -/service/uppercase
HELLO


Combining Secure Channels and Forwarders
------

We can also create a secure channel through Ockam Forwarders.

Forwarders enable an ockam node to register a forwarding address on another node.
Any message that arrives at this forwarding address is immediately dispatched
to the node that registered the forwarding address.

# Create three nodes
$ ockam node create relay

# Create a forwarder to node n2 at node relay
$ ockam forwarder create blue --at /node/relay --to /node/n2
/service/forward_to_n2

# Create an end-to-end secure channel between n1 and n2.
# This secure channel is created trough n2's forwarder at relay and we can
# send end-to-end encrypted messages through it.
$ ockam secure-channel create --from /node/n1 --to /node/relay/service/forward_to_n2/service/api \
    | ockam message send hello --from /node/n1 --to -/service/uppercase

In this topology `relay` acts an an encrypted relay between n1 and n2. n1 and
n2 can be running in completely separate private networks. The relay only sees encrypted
traffic and needs to be reachable from both n1 and n2.

This can be very useful in establishing end-to-end trustful communication between
applications that cannot otherwise reach each other over the network.

For instance, we can use forwarders to create an end-to-end secure channel between
two nodes that are behind private NATs.


List Secure Channels initiated from a node
------

$ ockam secure-channel list --node n1


Delete Secure Channels initiated from a node
------

$ ockam secure-channel delete 5f84acc6bf4cb7686e3103555980c05b --at n1


Custom Secure Channel Listeners
------

All node start with a secure channel listener at `/service/api` but you can also
start a custom listener with specific authorization policies.

# Create a secure channel listener on n1
$ ockam secure-channel-listener create test --at n2
/service/test

# Create a secure channel listener from n1 to our test secure channel listener on n2
$ ockam secure-channel create --from /node/n1 --to /node/n2/service/test
/service/09738b73c54b81d48531f659aaa22533
```
