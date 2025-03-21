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

# Kafka

Create an Ockam **Portal** to send end-to-end encrypted messages through Kafka - from any producer, to any consumer, _through_ any Kafka API compatible data streaming platform.

[<mark style="color:blue;">Ockam</mark>](<../../README (1).md>) encrypts messages from a Producer to a specific Consumer. Only that specific Consumer can decrypt these messages. This guarantees that your data cannot be observed or tampered as it passes through Kafka. Operators of the Kafka cluster only see end-to-end encrypted data. Any compromise of an operator's infrastructure cannot compromise your business data.

To learn how end-to-end trust is established, please read: “[<mark style="color:blue;">How does Ockam work?</mark>](../../how-does-ockam-work.md)”

<figure><img src="../../.gitbook/assets/portals-kafka.png" alt=""><figcaption></figcaption></figure>

Please select an example to dig in:

{% hint style="info" %}
The examples below use Apache Kafka, Redpanda, Confluent, Aiven, WarmStream and Instaclustr. However, the same setup works for any Kafka API compatible data streaming platform.
{% endhint %}

<table data-card-size="large" data-view="cards"><thead><tr><th></th><th></th><th data-hidden data-card-target data-type="content-ref"></th></tr></thead><tbody><tr><td><a href="apache-kafka/"><mark style="color:blue;"><strong>Apache Kafka</strong></mark></a></td><td>We send end-to-end encrypted messages through Apache Kafka.</td><td><a href="apache-kafka/">apache-kafka</a></td></tr><tr><td><a href="redpanda/"><mark style="color:blue;"><strong>Redpanda</strong></mark></a></td><td>We send end-to-end encrypted messages through Redpanda.</td><td><a href="redpanda/">redpanda</a></td></tr><tr><td><a href="instaclustr/"><mark style="color:blue;"><strong>Instaclustr</strong></mark></a></td><td>We send end-to-end encrypted messages through Instaclustr.</td><td><a href="instaclustr/">instaclustr</a></td></tr><tr><td><a href="confluent/"><mark style="color:blue;"><strong>Confluent</strong></mark></a></td><td>We send end-to-end encrypted messages through Confluent.</td><td><a href="confluent/">confluent</a></td></tr><tr><td><a href="aiven/"><mark style="color:blue;"><strong>Aiven</strong></mark></a></td><td>We send end-to-end encrypted messages through Aiven.</td><td><a href="aiven/">aiven</a></td></tr><tr><td><a href="warpstream/"><mark style="color:blue;"><strong>Warpstream</strong></mark></a></td><td>We send end-to-end encrypted messages through Warpstream.</td><td><a href="warpstream/">warpstream</a></td></tr></tbody></table>
