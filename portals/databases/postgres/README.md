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

In each example, we will connect a nodejs app in one private network with a postgres database in another private network.&#x20;

Each company’s network is private, isolated, and doesn't expose ports. To learn how end-to-end trust is established, please read: “[<mark style="color:blue;">How does Ockam work?</mark>](../../../how-does-ockam-work.md)”

<figure><img src="../../../.gitbook/assets/Screenshot 2024-02-11 at 1.32.40 PM.png" alt=""><figcaption></figcaption></figure>

Please select an example to dig in:

<table data-card-size="large" data-view="cards"><thead><tr><th></th><th></th></tr></thead><tbody><tr><td><a href="docker.md"><mark style="color:blue;"><strong>PostgresSQL - Docker</strong></mark></a></td><td>We connect a nodejs app in one virtual private network with a postgres database in another virtual private network. The example uses docker and docker compose to create these virtual networks.</td></tr><tr><td><a href="kubernetes.md"><mark style="color:blue;"><strong>PostgreSQL - Kubernetes</strong></mark></a></td><td>We connect a nodejs app in one private kubernetes cluster with a postgres database in another private kubernetes cluster. The example uses docker and kind to create these kubernetes clusters.</td></tr><tr><td><a href="aurora.md"><mark style="color:blue;"><strong>PostgreSQL - Amazon Aurora</strong></mark></a></td><td>We connect a nodejs app in one Amazon VPC with a Amazon Aurora managed Postgres database in another Amazon VPC. The example uses AWS CLI to create these VPCs.</td></tr><tr><td><a href="rds.md"><mark style="color:blue;"><strong>PostgreSQL - Amazon RDS</strong></mark></a></td><td>We connect a nodejs app in one Amazon VPC with a Amazon RDS managed Postgres database in another Amazon VPC. The example uses AWS CLI to create these VPCs.</td></tr></tbody></table>
