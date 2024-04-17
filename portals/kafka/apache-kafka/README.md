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

# Apache Kafka

In each example, we connect a kafka consumer and a producer in one private network with Apache kafka server in another private network. We send end-to-end encrypted Kafka messages _through_ Apache Kafka with Ockam.&#x20;

[<mark style="color:blue;">Ockam</mark>](../../../) encrypts Kafka messages so that only the consumer can decrypt it. This gives the guarantee of tamper-proof data transfer and eliminate exposure in case the Kafka messages are exposed.

<figure><img src="../../../.gitbook/assets/apache_kafka_docker.png" alt=""><figcaption></figcaption></figure>

Please select an example to dig in:

<table data-card-size="large" data-view="cards"><thead><tr><th></th><th></th></tr></thead><tbody><tr><td><a href="docker.md"><mark style="color:blue;"><strong>Kafka - Apache Kafka</strong></mark></a></td><td>We connect a kafka consumer and a producer in one private network with Apache kafka server in another private network. The example uses docker and docker compose to create these virtual networks.</td></tr></tbody></table>
