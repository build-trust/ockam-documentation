# Intro to Ockam

Ockam is a popular [Open Source library](https://github.com/build-trust/ockam) that empowers you to build secure-by-design apps that can trust data-in-motion. Hundreds of developers have contributed to building, reviewing the codebase over the past 5 years.

With Ockam:

* **Impossible connections become possible.** Establish secure channels between systems in private networks that previously could not be connected because it is either too difficult or insecure.
* **All public endpoints become private.** Connect your applications and databases without exposing anything publicly.

\
At its core, Ockam is a toolkit for developers to build applications that can create end-to-end encrypted, mutually authenticated, secure communication channels:

* **From anywhere to anywhere:** Ockam works across any network, cloud, or on prem infrastructure.&#x20;
* **Over any transport topology:** Ockam is compatible with every transport layer including TCP, UDP, Kafka, or even Bluetooth.
* **Without no infrastructure, network, or application changes:** Ockam works at the application layer, so you don’t need to make complex changes.&#x20;
* **While ensuring the risky things are impossible to get wrong:** Ockam’s protocols do the heavy lifting to establish end-to-end encrypted, mutually authenticated secure channels

### Why Ockam is so unique

Traditionally, connections made over TCP are secured with TLS. However, the security guarantees of a TLS secure channel only apply for the length of the underlying TCP connection. It is not possible to connect two systems in different private networks over a single TCP connection. Thus, connecting these two systems requires exposing one of them over the Internet, and breaking the security guarantees of TLS.

**Ockam works differently**. Our secure channel protocol sits on top of an application layer routing protocol. This routing protocol can hand over  messages from one transport layer connection to another. This can be done over any transport protocol, with any number of transport layer hops:  TCP to TCP to TCP, TCP to UDP to TCP, UDP to Bluetooth to TCP to Kafka, etc.&#x20;

Over these transport layer connections, Ockam sets up an end-to-end encrypted, mutually authenticated connection. This unlocks the ability to create secure channels between systems that live in entirely private networks, without exposing either end to the Internet.&#x20;

<figure><img src=".gitbook/assets/Screenshot 2025-02-19 at 7.25.34 PM.png" alt=""><figcaption><p>Examples of Ockam Secure Channels over multiple hops of TCP, Kafka, UDP, or anything else.</p></figcaption></figure>

Since Ockam’s routing protocol  is at the application layer, complex network and infrastructure changes are not required to make these connections. Rather than a months-long infrastructure project, you can connect private systems in minutes while ensuring the risky things are impossible to get wrong.&#x20;

* [x] NATs are traversed
* [x] Keys are stored in vaults
* [x] Credentials are short-lived
* [x] Messages are authenticated
* [x] Data-integrity is guaranteed
* [x] Senders are protected from key compromise impersonation
* [x] Encryption keys are ratcheted
* [x] Nonces are never reused
* [x] Strong forward secrecy is ensured
* [x] Sessions recover from network failures
* [x] ...and a lot more.

{% embed url="https://www.youtube.com/watch?ab_channel=Ockam&v=ufevCYmn8Do" %}

