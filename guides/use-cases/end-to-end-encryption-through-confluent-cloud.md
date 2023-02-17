---
description: True end-to-end encryption for data in motion
---

# End-to-end encryption through Confluent Cloud

Most organizations today have adopted cloud computing for some of their workloads. The increased agility and fewer things to manage results in more time to invest value-adding work. These can be just part of the rationale for using Confluent Cloud as the managed service to process Kafka streams. When using a managed service such as Confluent Cloud there is an implicit delegation of trust to their systems and the people that have access to them. If you're unwilling or unable (e.g., regulatory or compliance reasons) to delegate that trust then the suggested best practice is to message payload encryption to prevent the Confluent Cloud broker from being able to read all or part of your message payload.

### The problem

Both message producers and consumers will need to be updated to retrieve a key from a centralized key store such as AWS KMS or HashiCorp Vault, and use that key to encrypt and decrypt message payloads. While this has prevented Confluent Cloud from being able to eavesdrop on your message payloads, it's moved your vulnerability surface to a new location: your key store. If at any time your encryption key is leaked then not only is the attacker able to read all of your messages they would also be able to decrypt historical payloads that had used that same key.

### How Ockam simplifies it

Ockam's Confluent Cloud add-on is a drop-in solution at both the producer and consumer ends of your Kafka system that requires no code changes at either end. Via the Ockam protocol, the producer and consumer are able to directly generate and exchange credentials with each other which removes the vulnerability surface of a centralized and permanent keystore. The automatically rotating keys with forward secrecy also means that if a credential was ever leaked the risk is minimized to messages that are in-flight +/- the credential rotation period. The result is significant reductions in the likelihood of credential leak, the expoitable window of time if a leak did occur, and the amount of data exposed if it did occur.&#x20;

### Get started

