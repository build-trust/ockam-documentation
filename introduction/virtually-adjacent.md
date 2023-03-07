---
description: >-
  How to create virtual adjacencies between all of your distributed
  applications.
---

# Make distributed parts of your application Virtually Adjacent

Modern applications are delivered by composing together a variety of distributed services. Development teams focus on building only the parts that are core to their business and leverage third-party managed infrastructure and services for everything else.

This approach is fast and highly scalable but it also creates a lot of complexity and exponential growth in the **vulnerability surface of application data**. External services, that look like simple API calls or intermediaries in an application’s data flow path, are themselves complex systems. The vulnerability surfaces of all these dependencies get added to the vulnerability surface of core business data and make it _unmanageable and insecure_.

In multi-tenant cloud and edge environments, the network gateways, the load balancers, the caches, the queues, the event streaming engines, the compute environment etc. are all complicated systems that are themselves composed of hundreds of services with thousands of dependencies and millions of ways in which things can go wrong. Every time two distributed parts of an application communicate, application data is exposed to these external systems and networks that the application team doesn’t control.

How can developers **shift security left** and have **zero trust** in these things in the middle?

What if, virtually, you could think of all remote components of an application as **trustfully adjacent** to every other component. All security and trust concerns are abstracted away behind simple command line or function calls. All remote requests are authenticated and authorized. Data integrity and privacy is guaranteed end-to-end.

Ockam gives you this **virtual adjacency** so your application team has granular control over trust decisions in business logic without worrying about any of the implementation complexity.

Ockam Secure Channels and Portals make remote services local and encrypt all **data-in-motion**. The end-to-end data authenticity, integrity, and confidentiality guarantees, of these channels remove all implicit trust in any intermediaries that are in an application’s data flow path.

All parts of your application get unique, cryptographically provable identifiers. Ockam Orchestrator does all the heavy lifting – it manages discovery of routes and identities, ensures high availability of service endpoints, distributes short-lived credentials, facilitates mutually authenticated communication, and enforces policy driven access control.

When all remote components of an application become virtually adjacent to every other component, then the security and trust complexity of the entire network, the entire infrastructure, the entire internet is completely abstracted away. All third party intermediaries are removed from the app's vulnerability surface.

Let's get back to simple.
