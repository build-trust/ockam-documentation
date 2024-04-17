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

Create an Ockam **Portal** to send end-to-end encrypted Kafka messages - from any producer, to any consumer, _through_ any Kafka Broker.

[<mark style="color:blue;">Ockam</mark>](../../) encrypts Kafka messages so that only the consumer can decrypt it. This gives the guarantee of tamper-proof data transfer and eliminate exposure in case the Kafka messages are exposed.

In each example, we connect a kafka consumer and a producer in one private network with kafka server in another private network.&#x20;

Each company’s network is private, isolated, and doesn't expose ports. To learn how end-to-end trust is established, please read: “[<mark style="color:blue;">How does Ockam work?</mark>](../../how-does-ockam-work.md)”

<figure><img src="../../.gitbook/assets/portals-kafka.png" alt=""><figcaption></figcaption></figure>

Please select an example to dig in:

{% hint style="info" %}
The examples below use Apache Kafka and Redpanda, however, the same setup works for any Kafka datastreaming platforms: _Confluent, Aiven, WarpStream etc._
{% endhint %}

<table data-card-size="large" data-view="cards"><thead><tr><th></th><th></th><th data-hidden data-card-target data-type="content-ref"></th></tr></thead><tbody><tr><td><a href="apache-kafka/"><mark style="color:blue;"><strong>Apache Kafka</strong></mark></a></td><td>We connect a kafka consumer and a producer in one private network with Apache kafka server in another private network.</td><td><a href="apache-kafka/">Apache Kafka</a></td></tr><tr><td><a href="redpanda/"><mark style="color:blue;"><strong>Redpanda</strong></mark></a></td><td>We connect a kafka consumer and a producer in one private network with Redpanda kafka server in another private network.</td><td><a href="redpanda/">Redpanda</a></td></tr></tbody></table>
