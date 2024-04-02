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

# MongoDB

This section contains hands-on examples that use [<mark style="color:blue;">Ockam</mark>](../../../) to create **encrypted portals** to MongoDB databases running in various environments.

In each example, we connect a nodejs app in one private network with a MongoDB database in another private network.  To understand how end-to-end trust is established, and how the portal works even though the two networks are isolated with no exposed ports, please read: “[<mark style="color:blue;">How does Ockam work?</mark>](../../../how-does-ockam-work.md)”

<figure><img src="../../../.gitbook/assets/mongodb-portal.png" alt=""><figcaption></figcaption></figure>

Please select an example to dig in:

<table data-card-size="large" data-view="cards"><thead><tr><th></th><th></th></tr></thead><tbody><tr><td><a href="docker.md"><mark style="color:blue;"><strong>MongoDB - Docker</strong></mark></a></td><td>We connect a nodejs app in one virtual private network with a MongoDB database in another virtual private network. The example uses docker and docker compose to create these virtual networks.</td></tr></tbody></table>
