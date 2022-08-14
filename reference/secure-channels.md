# Secure Channels

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
