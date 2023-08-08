---
description: >-
  Secure by-design applications ensure that all machine-to-machine application layer communication
  is authenticated and authorized
---

# Apply fine-grained permissions with Attribute-Based Access Control (ABAC)

Modern applications are distributed and have an unwieldy number of interconnections that must
trustfully exchange data and instructions.

Authentication is a process where one entity gains assurances about the attributes of another
entity. In other words, it is a process of proving that you are who you say you are.

Authorization is the process of deciding if a request to access a resource should be granted. In
other words, it is a process that grants you the permission to do the "thing" that you are
attempting to do.

### The problem

In order to trust information or instructions, that are received over the network, applications must
**authenticate** all senders and **verify the integrity of data** **received** to assert what was
received is exactly what was sent — free from errors or en-route tampering.

Applications must also decide if a sender of a request is **authorized** to trigger the requested
action or view the requested data.

In scenarios where human users are authenticating with cloud services, we have some mature protocols
like OAuth 2.0 and OpenID Connect (OIDC) that help tackle parts of the problem.

However, majority of data that flows within modern applications doesn’t involve humans.
Microservices interact with other microservices, devices interact with other devices and cloud
services, internal services interact with partner systems and infrastructure services etc.

**Secure** **by-design** applications must ensure that all machine-to-machine application layer
communication is authenticated and authorized. For this, **applications must prove identifiers and
attributes.**

### How Ockam simplifies it

Attribute-Based Access Control (ABAC) is an authorization strategy that grants or denies access
based on attributes.

A subject’s request to perform an operation on a resource is granted or denied based on attributes
of the **subject**, attributes of the **operation**, attributes of the **resource**, and attributes
of the **environment**. Access is controlled using **policies** that are defined in terms of those
attributes.

### Next steps

- See an end-to-end example of this in our
  [<mark style="color:blue;">ABAC demo</mark>](../examples/abac.md).
- Follow our
  [<mark style="color:blue;">getting started guide to install Ockam</mark>](../../reference/command/README.md#install)
  and start using it in just a few minutes.
- [<mark style="color:blue;">Reach out to the team</mark>](https://www.ockam.io/contact/form), we'd
  love to talk to you in more detail about your potential use cases.
- Join the growing community of developers who want to build trust by making applications that are
  secure-by-design, in the
  [<mark style="color:blue;">Build Trust Discord server</mark>](https://discord.gg/RAbjRr3kds).
