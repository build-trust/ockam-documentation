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

# Confluent

Create an Ockam **Portal** to send end-to-end encrypted messages _through_ Confluent Cloud.

[<mark style="color:blue;">Ockam</mark>](<../../../README (1).md>) encrypts messages from a Producer all-of-the-way to a _specific_ Consumer. Only that _specific_ Consumer can decrypt these messages. This guarantees that your data cannot be observed or tampered with as it passes through Confluent Cloud or the network where it is hosted. The operators of Confluent Cloud can only see encrypted data in the network and in service that they operate. Thus, a compromise of the operator's infrastructure will not compromise the data stream's security, privacy, or integrity.

To learn how end-to-end trust is established, please read: “[<mark style="color:blue;">How does Ockam work?</mark>](../../../how-does-ockam-work.md)”

<figure><img src="../../../.gitbook/assets/confluent_cloud.png" alt=""><figcaption></figcaption></figure>

Please select an example to dig in:

<table data-card-size="large" data-view="cards"><thead><tr><th></th><th></th></tr></thead><tbody><tr><td><a href="confluent.md"><mark style="color:blue;"><strong>Confluent Cloud</strong></mark></a></td><td>Send end-to-end encrypted messages through Confluent Cloud.</td></tr></tbody></table>
