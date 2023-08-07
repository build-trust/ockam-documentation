---
description: >-
  Avoid long-lived assumptions about networks, stop exposing service ports to
  the public internet
---

# Secure database access

Whether you're using a relational database, NoSQL, graph database, a data lake, or anything similar you're almost certainly storing data that you do not want to be directly accessible to anybody who can find it. We've also seen over numerous years that common misconfiguration errors result in large numbers of databases being exposed due to easily guessable passwords. As a result, the first line of defense is avoid exposing your databases directly to the internet. Instead placing them inside a private subnet within your network.

### The problem

Following the best practice of placing your database inside a private subnet does an effective job of sealing it off from the rest of the internet, however the trade-off is overhead of granting exceptions to that policy. Network administrators will now need update network access control lists, security groups, and potentially route tables to allow other machines to open a connection to the database. In addition to the administrative overhead these solutions are inflexible and are not able to accommodate the increasingly dynamic needs of modern businesses. From dynamically scaling multi-region infrastructure to a distributed workforce working from various locations, supporting these needs through assumptions about specific network topology has become fragile and inefficient. How do you support a data scientist on your team who is working from a café, and who needs to connect their research notebook to your data warehouse? Do you require them to first connect via a VPN? Do they really need access to your entire corporate network while at a café?

### How Ockam simplifies it

<img src="../../.gitbook/assets/file.excalidraw (2) (1).svg" alt="" class="gitbook-drawing">

Through the use of authenticated secure channels your database is able to register itself as a service that some authorized subset of your Ockam nodes can connect to. By not requiring changes to network access control lists or security groups, no ports at all on your database are exposed to the public internet - an even higher security posture than the previous best practice.

As a result, the only way to establish a connection to the database is via an Ockam secure channel: an end-to-end encrypted and authenticated connection between the two nodes. These connections are established and authenticated on-demand. The just-in-time nature of this means no long-lived assumptions about what other networks or ports should be open and permanently allowed access to your database.

Service-to-database use cases can have more fine-grained control applied on top of this via [<mark style="color:blue;">Attribute-Based Access Control</mark>](../examples/). For restricting how people access services, such as the data scientist scenario outlined earlier, you can [<mark style="color:blue;">integrate with your Identity Provider</mark>](use-employee-attributes-from-okta-to-build-trust-with-cryptographically-verifiable-credentials.md).

### Next steps

* See an end-to-end example of this in our [<mark style="color:blue;">basic web app demo</mark>](../examples/basic-web-app.md).
* Follow our [<mark style="color:blue;">getting started guide to install Ockam</mark>](../../reference/command/#install) and start using it in just a few minutes.
* [<mark style="color:blue;">Reach out to the team</mark>](https://www.ockam.io/contact/form), we'd love to talk to you in more detail about your potential use cases.
* Join the growing community of developers who want to build trust by making applications that are secure-by-design, in the [<mark style="color:blue;">Build Trust Discord server</mark>](https://discord.gg/RAbjRr3kds).
