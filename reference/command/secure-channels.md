# Secure Channels

Now that we understand the basics of Nodes, Workers, and Routing ... let's create our first encrypted secure channel.

Establishing a secure channel requires establishing a shared secret key between the two entities that wish to communicate securely. This is usually achieved using a cryptographic key agreement protocol to safely derive a shared secret without transporting it over the network. In Ockam, we currently have support for two different key agreement protocols - one based on the Noise Protocol Framework and another based on Signal's X3DH design.

```shell-session
» ockam node create n1
» ockam node create n2

» ockam secure-channel create --from /node/n1 --to /node/n2/service/api

  Created Secure Channel:
  • From: /node/n1
  •   To: /node/n2/service/api (/ip4/127.0.0.1/tcp/64114/service/api)
  •   At: /service/dc2be3083629013034c5b81479ea565e

» ockam message send hello --from /node/n1 --to /service/dc2be3083629013034c5b81479ea565e/service/uppercase
HELLO

» ockam secure-channel create --from /node/n1 --to /node/n2/service/api \
    | ockam message send hello --from /node/n1 --to -/service/uppercase
HELLO
```
