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

# How does Ockam work?

Ockam is a stack of [<mark style="color:blue;">protocols</mark>](reference/protocols/) to build secure-by-design apps that can trust data-in-motion. We provide a collection of programming libraries, command line tools, deployable components, and cloud services that make it simple for you to use these protocols within your apps.

To understand how these protocols work together, let’s create an encrypted portal to a micro-service in another cloud. In that process, we’ll discuss questions that naturally arise: How is end-to-end trust established? How does it work even though the service is not exposed to the Internet?

<figure><img src=".gitbook/assets/postgres.png" alt=""><figcaption></figcaption></figure>

## Install and Enroll

{% tabs %}
{% tab title="homebrew" %}
```sh
brew install build-trust/ockam/ockam
ockam enroll
```
{% endtab %}

{% tab title="curl | bash" %}
```sh
curl --proto '=https' --tlsv1.2 -sSfL https://install.command.ockam.io | bash
source ~/.ockam/env
ockam enroll
```
{% endtab %}
{% endtabs %}

The first step is to install Ockam Command and enroll. The commands below can be run in a production setup with two machines in two different networks or in a dev environment on a single machine. If you’re doing this on two machines, install and enroll on both machines.

The enroll command creates a new [<mark style="color:blue;">vault</mark>](reference/protocols/keys.md) and generates a cryptographic [<mark style="color:blue;">identity</mark>](reference/protocols/identities.md) with private keys stored in that vault. It then guides you to sign in to Ockam Orchestrator.

If this is your first time signing in, the Orchestrator creates a new dedicated project for you. A project offers two services: a membership [<mark style="color:blue;">authority</mark>](reference/protocols/identities.md#credentials) and a [<mark style="color:blue;">relay</mark>](reference/protocols/routing.md#relay) service.

The enroll command then asks this project’s membership authority to sign and issue a [<mark style="color:blue;">credential</mark>](reference/protocols/identities.md#credentials) that attests that your [<mark style="color:blue;">identifier</mark>](reference/protocols/identities.md#identities) is a member of this project. Since your account in Orchestrator is the creator and hence first administrator on this new project, the membership authority issues this credential. The enroll command stores the credential for later use and exits.

<div data-full-width="true">

<figure><img src=".gitbook/assets/Screenshot 2024-02-06 at 11.15.36 AM.png" alt=""><figcaption></figcaption></figure>

</div>

## Create an Outlet and a Relay

{% code fullWidth="false" %}
```sh
ockam tcp-outlet create --to 5432
ockam relay create postgres
```
{% endcode %}

In Bank Corp’s AWS VPC, on the machine where postgres is running, create a tcp portal outlet.&#x20;

When this outlet receives messages from corresponding inlets, it unwraps all [<mark style="color:blue;">routing</mark>](reference/protocols/routing.md) information and sends raw tcp connections and segments to the postgres server on localhost port _5432_. Response segments from the tcp server are wrapped in [<mark style="color:blue;">routing</mark>](reference/protocols/routing.md) information and sent to corresponding inlets.

Next, create a relay in your project at address: _postgres_.

This command first creates an outgoing tcp connection from inside Bank Corp. to your project. It then creates a [<mark style="color:blue;">secure channel</mark>](reference/protocols/secure-channels.md) to your project over this tcp connection. This succeeds because Bank Corp’s network allows outgoing tcp connections to the Internet, and your Orchestrator project’s secure channel listener allows channels with project members.

Over this secure channel, the command then asks the relay service to create a [<mark style="color:blue;">relay</mark>](reference/protocols/routing.md#relay) at address: _postgres_. The relay is created because the [<mark style="color:blue;">access control</mark>](reference/protocols/access-controls.md) on the relay service allows authenticated project administrators to create relays at any address. When this relay receives messages, it routes them to the outlet node through the previously created secure channel and underlying tcp connection.

The default [<mark style="color:blue;">access control</mark>](reference/protocols/access-controls.md) on the outlet and the relay only allow messages from project members who have authenticated through a secure channel by presenting a [<mark style="color:blue;">credential</mark>](reference/protocols/identities.md#credentials) from the project membership authority that attests their [<mark style="color:blue;">identifier</mark>](reference/protocols/identities.md#identities) is a member of the project.

<div data-full-width="true">

<figure><img src=".gitbook/assets/Screenshot 2024-02-06 at 11.16.06 AM.png" alt=""><figcaption></figcaption></figure>

</div>

## Create an Inlet

```sh
ockam tcp-inlet create --from 15432 --to postgres
```

In Analysis Corp.’s Azure VNet, on the machine that has the postgres client, create a tcp portal inlet.

The inlet first creates a tcp listener on localhost port _15432_. It then creates an outgoing tcp connection from inside Analysis Corp. to your project. Next, it creates a [<mark style="color:blue;">secure channel</mark>](reference/protocols/secure-channels.md) to your project over this tcp connection. Finally, it creates an end-to-end secure channel to the outlet node in Bank Corp. through the relay in your project at address: _postgres._

Over this end-to-end secure channel the inlet creates a **portal** with the outlet.

All secure channels are mutually authenticated and all messages are checked for authorization. The default [<mark style="color:blue;">access control</mark>](reference/protocols/access-controls.md) on the inlet only allows messages from project members who have authenticated through a secure channel by presenting a [<mark style="color:blue;">credential</mark>](reference/protocols/identities.md#credentials) from the project membership authority that attests their [<mark style="color:blue;">identifier</mark>](reference/protocols/identities.md#identities) is a member of the project.

<div data-full-width="true">

<figure><img src=".gitbook/assets/Screenshot 2024-02-06 at 11.16.33 AM.png" alt=""><figcaption></figcaption></figure>

</div>

## Connect

```bash
psql --host localhost --port 15432
```

In Analysis Corp.’s Azure VNet, connect with the **virtually adjacent** postgres on _localhost:15432_.

When a tcp connection is created with this inlet at _localhost:15432,_ it wraps tcp segments in [<mark style="color:blue;">routing</mark>](reference/protocols/routing.md) messages and sends them through the portal. Messages are encrypted inside Analysis Corp. and decrypted only when they are inside Bank Corp. The outlet in Bank Corp. unwraps routing information and sends raw tcp segments to the tcp server.

The outlet sends response segments from the tcp server back through the portal. Response messages are encrypted inside Bank Corp. and decrypted only when they are inside Analysis Corp. The inlet unwraps all [<mark style="color:blue;">routing</mark>](reference/protocols/routing.md) information and sends raw tcp response segments to the tcp client.

<div data-full-width="true">

<figure><img src=".gitbook/assets/Screenshot 2024-02-06 at 11.32.24 AM.png" alt=""><figcaption></figcaption></figure>

</div>

## Recap

We ran a few simple commands to securely connect with a micro-service in another cloud. The postgres server in Bank Corp. became **virtually adjacent** to the postgres client in Analysis Corp.

<figure><img src=".gitbook/assets/postgres.png" alt=""><figcaption></figcaption></figure>

In this example, we used a postgres server and client. However, the same commands work for any tcp server and client, such as an http server serving an api built with express or django. We have to adjust some port numbers, but other than that, the tcp server and client remain unchanged. Ockam runs as a companion next to the server and its clients.

Sensitive business data in the postgres database is only accessible to Bank Corp. and  Analysis Corp. All data is [<mark style="color:blue;">encrypted</mark>](reference/protocols/secure-channels.md) with strong forward secrecy as it moves through the Internet. The communication channel is [<mark style="color:blue;">mutually authenticated</mark>](reference/protocols/secure-channels.md) and [<mark style="color:blue;">authorized</mark>](reference/protocols/access-controls.md). Keys and credentials are automatically rotated. Access to connect with postgres can be easily revoked.

Analysis Corp. does not get unfettered access to Bank Corp.’s network. It gets access only to run queries on the postgres server. Bank Corp. does not get unfettered access to Analysis Corp.’s network. It gets access only to respond to queries over a tcp connection. Bank Corp. cannot initiate connections.

All [<mark style="color:blue;">access controls</mark>](reference/protocols/access-controls.md) are secure-by-default. Only project members, with valid credentials, can connect with each other. More granular attribute-based authorization policies can be easily defined to control which inlets can connect with which outlets and vice-versa.

NAT’s are traversed using a relay and outgoing tcp connections. Bank Corp. or Analysis Corp. don’t expose any listening endpoints on the Internet. Their networks are completely closed and protected from any attacks from the Internet. Ockam’s [<mark style="color:blue;">routing</mark>](reference/protocols/routing.md) protocol enables multiple ways of traversing NAT’s with various tradeoffs, the relay approach is highly secure and always works.

The above example gave us peek at how Ockam’s stack of [<mark style="color:blue;">protocols</mark>](reference/protocols/) work together to ensure security, privacy, and trust in data. In this case we deployed Ockam as a companion next to a server and its clients. This approach can support a very large variety of use cases. Our programming libraries take this further and empower your to build trust in ways that are tailored to your business.
