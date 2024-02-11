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

This section contains hands-on examples that use [Ockam](../../../) to create an **encrypted portals** to postgres running in various environments.

In each of the following examples, we connect a nodejs app in one private network with a postgres database in another private network. The database doesn’t need to be exposed to the Internet.

<figure><img src="../../../.gitbook/assets/Screenshot 2024-02-09 at 8.51.05 AM (3).png" alt=""><figcaption></figcaption></figure>

<table data-card-size="large" data-view="cards"><thead><tr><th></th><th></th><th></th></tr></thead><tbody><tr><td><a href="docker.md"><mark style="color:blue;"><strong>Postgres - Docker</strong></mark></a></td><td>We connect a nodejs app in one virtual private network with a postgres database in another virtual private network. The example uses docker and docker compose to create these virtual networks.</td><td></td></tr></tbody></table>
