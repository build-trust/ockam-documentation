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

This section contains hands-on examples that use [<mark style="color:blue;">Ockam</mark>](../../../) to create **encrypted portals** to postgres databases running in various environments.

In each example, we connect a nodejs app in one private network with a postgres database in another private network.  To understand how end-to-end trust is established, and how the portal works even though the two networks are isolated with no exposed ports, please read: “[<mark style="color:blue;">How does Ockam work?</mark>](../../../how-does-ockam-work.md)”

<figure><img src="../../../.gitbook/assets/Screenshot 2024-02-11 at 1.32.40 PM.png" alt=""><figcaption></figcaption></figure>

Please select an example to dig in:

<table data-card-size="large" data-view="cards"><thead>
<tr><th></th><th></th></tr></thead><tbody><tr><td><a href="docker.md"><mark style="color:blue;"><strong>PostgresSQL - Docker</strong></mark></a></td><td>We connect a nodejs app in one virtual private network with a postgres database in another virtual private network. The example uses docker and docker compose to create these virtual networks.</td></tr>
<tr><td><a href="kubernetes.md"><mark style="color:blue;"><strong>PostgreSQL - Kubernetes</strong></mark></a></td><td>We connect a nodejs app in one private kubernetes cluster with a postgres database in another private kubernetes cluster. The example uses docker and kind to create these kubernetes clusters.</td></tr></tbody>
<tr><td><a href="aurora.md"><mark style="color:blue;"><strong>PostgreSQL - AWS Aurora</strong></mark></a></td><td>We connect a nodejs app in one private AWS network with a postgres database, using the [<mark style="color:blue;">Aurora service</mark>](https://aws.amazon.com/rds/aurora/), in another private AWS network. The example uses the AWS CLI to instantiate the AWS resources.</td></tr></tbody>
<tr><td><a href="rds.md"><mark style="color:blue;"><strong>PostgreSQL - AWS RDS</strong></mark></a></td><td>We connect a nodejs app in one private AWS network with a postgres database, using the [<mark style="color:blue;">RDS service</mark>](https://aws.amazon.com/rds), in another private AWS network. The example uses the AWS CLI to instantiate the AWS resources.</td></tr></tbody>
</table>
