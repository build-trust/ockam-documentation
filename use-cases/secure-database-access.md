---
description: >-
  Avoid long-lived assumptions about networks, stop exposing service ports to
  the public internet
---

# Secure database access

Whether you're using a relational database, NoSQL, graph database, a data lake, or anything similar you're almost certainly storing data that you do not want to be directly accessible to anybody who can find it. We've also seen over numerous years that common misconfiguration errors result in large numbers of databases being exposed due to easily guessable passwords. As a result, the first line of defence is avoid exposing your databases directly to the internet. Instead placing them inside a private subnet within your network.

### The problem

Following the best practice of placing your database inside a private subnet does an effective job of sealing it off from the rest of the internet, however the trade-off is overhead of granting exceptions to that policy. Network administrators will now need update network access control lists, security groups, and potentially route tables to allow other machines to open a connection to the database. In addition to the administrative overhead these solutions are inflexible and are not able to accomodate the increasingly dynamic needs of modern businesses. From dynamically scaling multi-region infrastructure to a distributed workforce working from various locations, supporting these needs through assumptions about specific network topology has become fragile and inefficient. How do you support a data scientist on your team who is working from a café, and who needs to connect their research notebook to your data warehouse? Do you require them to first connect via a VPN? Do they really need access to your entire corporate network while at a café?

### How Ockam simplifies it

Through the use of authenticated secure channels your database is able to register itself as a service that some authorized subset of your Ockam nodes can connect to. By not requiring changes to network access control lists or security groups, no ports at all on your database are exposed to the public internet - an even higher security posture than the previous best practice.&#x20;

As a result, the only way to establish a connection to the database is via an Ockam secure channel: an end-to-end encrypted and authenticated connection between the two nodes. These connections are established and authenticated on-demand. The just-in-time nature of this means no long-lived assumptions about what other networks or ports should be open and permanently allowed access to your database.

Service-to-database use cases can have more fine-grained control applied on top of this via [Attribute-Based Access Control](../examples/). For restricting how people access services, such as the data scientist scenario outlined earlier, you can [integrate with your Identity Provider](use-employee-attributes-from-okta-to-build-trust-with-cryptographically-verifiable-credentials.md).

### Get started

You can see an end-to-end example of this in our [basic web app demo](../examples/basic-web-app.md), or follow our getting started guide to install Ockam and start using it in just a few minutes.

We'd also love to talk to you in more detail about your potential use cases, so [please reach out to the team](https://www.ockam.io/contact/form) to chat.

