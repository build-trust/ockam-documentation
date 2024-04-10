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

This section contains hands-on examples that use [<mark style="color:blue;">Ockam</mark>](../../) to create **encrypted portals** to various databases running in various environments.

In each example, we connect a nodejs app in one private network with a database in another private network. To understand how end-to-end trust is established, and how the portal works even though the two networks are isolated with no exposed ports, please read: “[<mark style="color:blue;">How does Ockam work?</mark>](../../how-does-ockam-work.md)”

<figure><img src="../../.gitbook/assets/Screenshot 2024-02-11 at 1.32.40 PM.png" alt=""><figcaption></figcaption></figure>

Please select an example to dig in:

{% hint style="info" %}
The examples below use PostgreSQL, MongoDB and InfluxDB. However, the same setup works for any database: _MySQL, ClickHouse, Cassandra, SQL Server, etc._
{% endhint %}

<table data-card-size="large" data-view="cards"><thead><tr><th></th><th></th><th data-hidden data-card-target data-type="content-ref"></th></tr></thead><tbody><tr><td><a href="postgres/"><mark style="color:blue;"><strong>PostgreSQL</strong></mark></a></td><td>We connect a nodejs app in one private network with a PostgreSQL database in another private network.</td><td><a href="postgres/">postgres</a></td></tr><tr><td><a href="mongodb/"><mark style="color:blue;"><strong>MongoDB</strong></mark></a></td><td>We connect a nodejs app in one private network with a MongoDB database in another private network.</td><td><a href="mongodb/">mongodb</a></td></tr><tr><td><a href="influxdb/"><mark style="color:blue;"><strong>InfluxDB</strong></mark></a></td><td>We connect a nodejs app in one private network with a InfluxDB database in another private network.</td><td><a href="influxdb/">influxDB</a></td></tr></tbody></table>


