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

# Redpanda

Create an Ockam **Portal** to send end-to-end encrypted messages _through_ Redpanda.

[<mark style="color:blue;">Ockam</mark>](../../../) encrypts messages as they leave a Producer in such a way that they can only be decrypted by a specific Consumer. This guarantees that your data cannot be seen or tampered as it passes through Kafka. Operators of the Kafka cluster only see end-to-end encrypted data.

<figure><img src="../../../.gitbook/assets/redpanda_docker.png" alt=""><figcaption></figcaption></figure>

Please select an example to dig in:

<table data-card-size="large" data-view="cards"><thead><tr><th></th><th></th></tr></thead><tbody><tr><td><a href="docker.md"><mark style="color:blue;"><strong>Redpanda - Docker</strong></mark></a></td><td>We send end-to-end encrypted messages through Redpanda.</td></tr></tbody></table>
