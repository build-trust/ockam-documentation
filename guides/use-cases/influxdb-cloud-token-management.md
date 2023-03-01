---
description: >-
  Improve security of your InfluxDB Cloud database with automated token/key
  revocation.
---

# InfluxDB Cloud token management

InfluxDB is often used as a time-series database that hundreds, if not thousands, of clients are regularly writing data to.&#x20;

### The problem

Managing client access credentials for thousands of discrete clients can be a challenge for customers at scale. Creating unique credentials, and then providing those credentials to each unique client, is both an operational and engineering burden. Best-practice would recommend regularly auditing and rotating those credentials to reduce the risk the the business should a credential be exposed which results in an on-going operational complexity that continues to increase as the number of clients grows. Some companies may instead opt to have a single credential that is shared across all clients to reduce the operational complexity though that comes with an increase in risk and remediation complexity if that credential is ever exposed.

### How Ockam simplifies it

The InfluxDB add-on for Ockam automates token management for InfluxDB Cloud. By leveraging the existing enrollment and identity capabilities built-in to Ockam, customers can have each client request a set of unique credentials. Ockam Orchestrator will then generate a fine-grained set of access permissions, alongside a predetermined time-to-live (TTL) for the token. At the end of the TTL the credentials will be automatically revoked and the client can repeat the process to retrieve a new set of credentials.&#x20;

By integrating directly with InfluxDB, Ockam is able to provide a solution that works seamlessly with any other InfluxDB sources (e.g., Telegraf, language SDKs, HTTP) and reduces security risks without increasing operational complexity.

### Get started

You can see an example of this in our [InfluxDB Cloud token lease management](../examples/influxdb-cloud-token-lease-management.md) demo, or follow our [getting started guide to install Ockam](broken-reference) and start using it in just a few minutes.

We'd also love to talk to you in more detail about your potential use cases, so [please reach out to the team](https://www.ockam.io/contact/form) to chat.
