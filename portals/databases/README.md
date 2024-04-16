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

# Databases

Create an Ockam **Portal** between any application, to any database, in any environment.

In each example, we connect a nodejs app in one private network with a database in another private network.&#x20;

Each company’s network is private, isolated, and doesn't expose ports. To learn how end-to-end trust is established, please read: “[<mark style="color:blue;">How does Ockam work?</mark>](../../how-does-ockam-work.md)”

<figure><img src="../../.gitbook/assets/Screenshot 2024-02-11 at 1.32.40 PM.png" alt=""><figcaption></figcaption></figure>

Please select an example to dig in:

{% hint style="info" %}
The examples below use PostgreSQL and MongoDB, however, the same setup works for any database: _MySQL, ClickHouse, Cassandra, InfluxDB, SQL Server, etc._
{% endhint %}

<table data-card-size="large" data-view="cards"><thead><tr><th></th><th></th><th data-hidden data-card-target data-type="content-ref"></th></tr></thead><tbody><tr><td><a href="postgres/"><mark style="color:blue;"><strong>PostgreSQL</strong></mark></a></td><td>We connect a nodejs app in one private network with a PostgreSQL database in another private network.</td><td><a href="postgres/">postgres</a></td></tr><tr><td><a href="mongodb/"><mark style="color:blue;"><strong>MongoDB</strong></mark></a></td><td>We connect a nodejs app in one private network with a MongoDB database in another private network.</td><td><a href="mongodb/">mongodb</a></td></tr></tbody></table>
