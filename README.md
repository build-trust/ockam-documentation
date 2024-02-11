---
layout:
  title:
    visible: true
  description:
    visible: false
  tableOfContents:
    visible: true
  outline:
    visible: true
  pagination:
    visible: true
---

# What is Ockam?

Ockam empowers you to build secure-by-design apps that can trust data-in-motion.

You can use Ockam to create end-to-end encrypted and mutually authenticated channels. Ockam secure channels authenticate using cryptographic identities and credentials. They give your apps granular control over all trust and access decisions. This control makes it easy to enforce fine-grained, attribute-based authorization policies – at scale.

These core capabilities enable private and secure communication in a wide variety of application architectures. For example, with one simple command an app in your cloud can create an encrypted portal to a micro-service in another cloud. The service doesn’t need to be exposed to the Internet. You don’t have to change anything about networks or firewalls.

{% code fullWidth="false" %}
```sh
# Create a TCP Portal Inlet to a Postgres server that is running in
# a remote private VPC in another cloud.
ockam tcp-inlet create --from 15432 --to postgres

# Access the Postgres server on localhost.
psql --host localhost --port 15432
```
{% endcode %}

<figure><img src=".gitbook/assets/postgres (1).png" alt=""><figcaption></figcaption></figure>

Similarly, using another simple command a kafka producer can publish end-to-end encrypted messages for a specific kafka consumer. Kafka brokers in the middle can’t see, manipulate, or accidentally leak sensitive enterprise data. This minimizes risk to sensitive business data and makes it easy to comply with data governance policies.

The underlying [<mark style="color:blue;">protocols</mark>](reference/protocols/) handle the hard parts — NATs are traversed; Keys are stored in vaults; Credentials are short-lived; Messages are authenticated; Data-integrity is guaranteed; Senders are protected from key compromise impersonation; Encryption keys are ratcheted; Nonces are never reused; Strong forward secrecy is ensured; Sessions recover from network failures; and a lot more.

The above examples are two of many ways in which your apps can leverage Ockam to ensure security, privacy, and trust in data. You can deploy Ockam as a companion next to existing apps or use our programming libraries to build trust in ways that are tailored to your business.
