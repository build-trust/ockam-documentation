---
description: >-
  Ockam Secure Channels are mutually authenticated and end-to-end encrypted
  messaging channels that guarantee data authenticity, integrity, and
  confidentiality.
---

# Secure Channels

In previous sections we saw how Ockam [<mark style="color:blue;">Routing</mark>](routing.md) and [<mark style="color:blue;">Transports</mark>](routing.md#transport)<mark style="color:blue;">,</mark> when combined with the ability to model [<mark style="color:blue;">Bridges</mark>](advanced-routing.md) and [<mark style="color:blue;">Relays</mark>](advanced-routing.md#relay), make it possible to <mark style="color:orange;">create end-to-end, application layer protocols in</mark> <mark style="color:orange;"></mark><mark style="color:orange;">**any**</mark> <mark style="color:orange;"></mark><mark style="color:orange;">communication topology</mark> - across networks, clouds, and protocols.

Ockam Secure Channels is an end-to-end protocol build on top of Ockam Routing. Once a channel is established, it provides the following <mark style="color:orange;">end-to-end guarantees</mark>:

1. **Authenticity:** Each end of the channel knows that messages received on the channel must have been sent by someone who possesses the secret keys of specific Ockam Identifier.
2. **Integrity:** Each end of the channel knows that the messages received on the channel could not have been tapered en-route and are exactly what was sent by the authenticated sender at the other end of the channel.
3. **Confidentiality:**  Each end of the channel knows that the contents of messages received on the channel could not have been observed en-route between the sender and the receiver.

Establishing a secure channel requires establishing shared secret keys between the two entities that wish to communicate securely. This is achieved using a cryptographic [key agreement protocol](../protocols/secure-channels.md) to safely derive shared secrets without transporting these secrets on the wire.

<img src="../../.gitbook/assets/file.excalidraw (1).svg" alt="" class="gitbook-drawing">



Once the shared sec



Ockam [<mark style="color:blue;">Secure Channels</mark>](secure-channels.md) can provide end-to-end guarantees of data authenticity, integrity, and confidentiality in any of the above communication topologies. In contrast, traditional secure communication implementations are typically tightly coupled with transport protocols in a way that all their security is limited to the length and duration of the underlying transport connections.

For example, most TLS implementations are tightly coupled with the underlying TCP connection. If your application’s data and requests travel over two TCP connection hops `TCP -> TCP` then all TLS guarantees break at the bridge between the two networks. This bridge, gateway or load balancer then becomes a point of weakness for application data.

To make matters worse, if you don't setup another mutually authenticated TLS connection on the second hop between the gateway and your destination server then the entire second hop network – that may have thousands of applications and machines within it – becomes an attack vector to your application and its data. If any of these neighboring applications or machines are compromised then your application and its data can be easily compromised.

Traditional secure communication protocols are also unable to protect your application’s data if it travels over multiple different transport protocols. They can’t guarantee data authenticity or data integrity if your application’s communication path is `UDP -> TCP` or `BLE -> TCP`.









```
» ockam project information --output json > project.json

» ockam node create n1 --project project.json
» ockam node create n3 --project project.json

» ockam forwarder create n3 --at /project/default --to /node/n3
/service/forward_to_n3

» ockam secure-channel create --from n1 --to /project/default/service/forward_to_n3/service/api \
    | ockam message send hello --from n1 --to -/service/uppercase
HELLO
```



