---
description: >-
  Improve security of your InfluxDB Cloud database with automated token/key
  revocation.
---

# InfluxDB Cloud token management

InfluxDB is used as a time-series database that hundreds, if not thousands, of clients are regularly writing data to.

### The problem

Managing client access credentials for thousands of discrete clients can be a challenge for customers at scale. Creating unique credentials, and then providing those credentials to each unique client, is both an operational and engineering burden. Best practice recommends regularly auditing and rotating credentials to reduce the risk to the business in the event of credential exposure. However, this practice can lead to ongoing operational complexity, which further increases as the number of clients grows. Some companies may instead opt to have a single credential that is shared across all clients to reduce the operational complexity, though that comes with an increase in risk and remediation complexity if that credential is ever exposed.

### How Ockam simplifies it

<img src="../../.gitbook/assets/file.excalidraw (2).svg" alt="" class="gitbook-drawing">

The InfluxDB add-on for Ockam automates token management for InfluxDB Cloud. By leveraging the existing enrollment and identity capabilities built-in to Ockam, customers can have each client request a set of unique credentials. Ockam Orchestrator will then generate a fine-grained set of access permissions, alongside a predetermined time-to-live (TTL) for the token. At the end of the TTL the credentials will be automatically revoked and the client can repeat the process to retrieve a new set of credentials.

By integrating directly with InfluxDB, Ockam is able to provide a solution that works seamlessly with any other InfluxDB sources (e.g., Telegraf, language SDKs, HTTP) and reduces security risks without increasing operational complexity.

### Next steps

* See an example of this in our [<mark style="color:blue;">InfluxDB Cloud token lease management</mark>](../examples/influxdb-cloud-token-lease-management.md) demo.
* Follow our [<mark style="color:blue;">getting started guide to install Ockam</mark>](../../reference/command/#install) and start using it in just a few minutes.
* [<mark style="color:blue;">Reach out to the team</mark>](https://www.ockam.io/contact/form), we'd love to talk to you in more detail about your potential use cases.
* Join the growing community of developers who want to build trust by making applications that are secure-by-design, in the [<mark style="color:blue;">Build Trust Discord server</mark>](https://discord.gg/RAbjRr3kds).
