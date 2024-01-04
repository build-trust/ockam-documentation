---
description: Fine-grained access control between specific services rather than networks
---

# SaaS vendors connecting to customers' private systems

Modern infrastructure deployments are typically spread across a range of cloud platforms and managed services. Even companies that are "all in" with a cloud-native approach will have some systems that are running on infrastructure they directly manage themselves, and other systems that are provided as a managed solution.

As a Software as a Service (SaaS) provider your customers will require the ability to connect your solution to this systems in order to realize the full potential of your offering. Being able to connect to data in private databases or integrate with on-prem/self-hosted Version Control Systems has become core requirement for many SaaS platforms.

### The problem

Your customers are unwilling to compromise their security posture to integrate with your platform, and require an architecture that limits access to their private services to only those parties that need access. The most common approaches to addressing this requirement are one of the following:

* Publicly accessible services: ask the customer to make the required services accessible via the internet.
* Virtual Private Network (VPN): have the customer setup a VPN that securely connects the network of the SaaS platform with the network of the customer.

The problem with a publicly accessible services approach is that services are exposed to the entire internet. Access control restrictions are pushed entirely to the authentication layer and thus anybody with valid credentials will be granted access to the service. With service ports available to the entire internet the service is now vulnerable to a Denial of Service (DoS) attack. Many SaaS providers will publish list of IP addresses that requests will come from so that customers can mitigate this risk by restricting access at a network level to expected IP ranges. This pushes an on-going operational burden to both the SaaS provider and the customer: The provider must have a process to pre-emptively update the list prior to any changes, and customers must build tooling to detect changes and update their network configuration accordingly. Failure to do so on either side jeopardizes service availability. It also a brittle approach that restricts the SaaS provider's ability to embrace a cloud-first approach to dynamic scaling.

A VPN based approach instead creates a secure connection from the network where the SaaS platform is running to network where the private service is located. This is a significant improvement from a publicly accessible services model, but it's still overly expansive in terms of the access it grants. As it's connecting _networks_ on each side it risks exposing connectivity to a larger footprint of infrastructure than is required. Customers would need to put further network access restrictions in place, or reconsider their network architecture to isolate the service(s) in question from the rest of their infrastructure. Asking customers to rearchitect their network to enable them to use your product securely should be a last resort.

### How Ockam simplifies it

<img src="../../.gitbook/assets/file.excalidraw.svg" alt="" class="gitbook-drawing">

Your customer is able to run an Ockam process alongside the service they want to make available, either by using the Ockam Command directly or embedded into a custom agent you provide as part of your solution. The Ockam process enrolls with Orchestrator and defines what other components are permitted to access it. No ports or networks are exposed to the internet at any point.

Within your SaaS platform you can use the Ockam programming libraries (or alternatively use Ockam Command) to integrate Ockam directly into your application. When required your service can initiate a connection to Ockam Orchestrator that, if authentication is successful and meets the customer's policy controls, establishes a secure channel to the Ockam process running on the customer's private infrastructure. Each process will generate its own credentials, and they will exchange those credentials directly with each other. This ensures that not only is all traffic between these systems guaranteed to be encrypted, but that only those authenticated nodes are able to communicate with each other. No other services on either network can communicate over this secure channel.

### Next steps

* Follow our [<mark style="color:blue;">getting started guide to install Ockam</mark>](../../reference/command/#install) and start using it in just a few minutes.
* [<mark style="color:blue;">Reach out to the team</mark>](https://www.ockam.io/contact/form), we'd love to talk to you in more detail about your potential use cases.
* Join the growing community of developers who want to build trust by making applications that are secure-by-design, in the [<mark style="color:blue;">Build Trust Discord server</mark>](https://discord.gg/RAbjRr3kds).
