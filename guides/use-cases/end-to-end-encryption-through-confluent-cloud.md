---
description: True end-to-end encryption for data in motion
---

# End-to-end encryption through Confluent Cloud

Most organizations today have adopted cloud computing for some of their workloads. The increased agility and fewer things to manage results in more time to invest value-adding work. These can be just part of the rationale for using Confluent Cloud as the managed service to process Kafka streams. When using a managed service such as Confluent Cloud there is an implicit delegation of trust to their systems and the people that have access to them.

### The problem

Some companies may be unwilling or unable (e.g., regulatory or compliance reasons) to completely delegate that trust. Having a third party, such as a managed Kafka broker, that can theoretically read and process messages as they transit through their systems does not meet their obligations around data access controls. Developers that have implemented a working solution are now faced with having to find a new approach that addresses the security concerns or abandoning the enitre project and starting again. One approach is to reimplement the Kafka producers and consumers to use a shared encryption key to encrypt and decrypt the message payloads. This additional work technically meets security concerns, but it does so by shifting the vulnerability surface to be across two systems: Confluent Cloud and your centralized key store. Exfilitration of a credential or encryption key means that all current _and historical_ data could be decrypted and exposed.

### How Ockam simplifies it

Ockam's Confluent Cloud add-on is a drop-in solution at both the producer and consumer ends of your Kafka system that requires no code changes at either end. Via the Ockam protocol, the producer and consumer are able to directly generate and exchange credentials with each other which removes the vulnerability surface of a centralized and permanent keystore. The automatically rotating keys with forward secrecy also means that if a credential was ever leaked the risk is minimized to messages that are in-flight +/- the credential rotation period. The result is significant reductions in the likelihood of credential leak, the expoitable window of time if a leak did occur, and the amount of data exposed if it did occur.&#x20;

### Next steps

* See an example of this in our [<mark style="color:blue;">end-to-end encrypted Kafka</mark>](../examples/end-to-end-encrypted-kafka.md) demo.
* Follow our [<mark style="color:blue;">getting started guide to install Ockam</mark>](../../reference/command/README.md#install) and start using it in just a few minutes.
* [<mark style="color:blue;">Reach out to the team</mark>](https://www.ockam.io/contact/form), we'd love to talk to you in more detail about your potential use cases.
* Join the growing community of developers who want to build trust by making applications that are secure-by-design, in the [<mark style="color:blue;">Build Trust Discord server</mark>](https://discord.gg/RAbjRr3kds).
