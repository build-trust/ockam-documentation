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

# PostgreSQL

This section contains hands-on examples that use [Ockam](../../../) to create **encrypted portals** to postgres database running in various environments.

In each example, we connect a nodejs app in one private network with a postgres database in another private network.  To understand how end-to-end trust is established, and how the portal works even though the two networks are isolated with no exposed ports, please read: “[<mark style="color:blue;">How does Ockam work?</mark>](../../../how-does-ockam-work.md)”

<figure><img src="../../../.gitbook/assets/Screenshot 2024-02-09 at 8.51.05 AM (3).png" alt=""><figcaption></figcaption></figure>

Please pick and example to dig in:

<table data-card-size="large" data-view="cards"><thead><tr><th></th><th></th></tr></thead><tbody><tr><td><a href="docker.md"><mark style="color:blue;"><strong>PostgresSQL - Docker</strong></mark></a></td><td>We connect a nodejs app in one virtual private network with a postgres database in another virtual private network. The example uses docker and docker compose to create these virtual networks.</td></tr></tbody></table>
