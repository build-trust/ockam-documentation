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

# Get started demo

Let’s build a simple example together. We will create an encrypted[ Ockam Portal](https://docs.ockam.io/#portals) from a psql microservice in Azure to a Postgres Database in AWS.

When you get done with this page you will understand

1. the basic building blocks of Ockam,
2. the first steps you should take in your architecture, and
3. how to build an end-to-end encrypted portal between two private services.

<figure><img src=".gitbook/assets/postgres.png" alt=""><figcaption></figcaption></figure>

## Create an Orchestrator Project

[Sign up for Ockam](https://www.ockam.io/download) and pick a subscription plan through the guided workflow on Ockam.io.\
\
After you complete this step you will have a Project in Ockam Orchestrator. A Project offers two services: a Membership[ Authority](https://docs.ockam.io/reference/protocols/identities#credentials) and a[ Relay](https://docs.ockam.io/reference/protocols/routing#relay) service. More on both of those later.

<figure><img src=".gitbook/assets/image (9).png" alt=""><figcaption></figcaption></figure>

## Set up Command on your local dev machine

Run the following commands to install Ockam Command on your dev machine.

{% code fullWidth="false" %}
```bash
curl --proto '=https' --tlsv1.2 -sSfL https://install.command.ockam.io | bash
source "$HOME/.ockam/env"

ockam enroll
```
{% endcode %}

The \`enroll\` command does a lot!  All at once it...

1. creates an Ockam Node on your machine.
2. generates a private key [Identifier](https://docs.ockam.io/reference/protocols/identities#identities) as your local Node’s cryptographic[ Identity](https://docs.ockam.io/reference/protocols/identities).&#x20;
3. creates a local [Vault to store keys.](https://docs.ockam.io/reference/protocols/keys)
4. guides you to sign in to your new Ockam Orchestrator Project.&#x20;
5. asks your Project’s Membership Authority to issue and sign a[ membership Credential](https://docs.ockam.io/reference/protocols/identities#credentials) for this Node.
6. makes you the administrator of your Project.
7. creates a Secure Channel between your local Ockam Node and your Project in Orchestrator.

Congrats! Your dev machine Node has a secure, encrypted Ockam Portal connection to your Project Node inside of Ockam Orchestrator over a Secure Channel!

<figure><img src=".gitbook/assets/image (1).png" alt=""><figcaption></figcaption></figure>

## Install Ockam Command and create an Ockam Node in AWS

```bash
curl --proto '=https' --tlsv1.2 -sSfL https://install.command.ockam.io | bash
source "$HOME/.ockam/env"

ockam enroll
```

The process is repeated in AWS through the same set of commands.&#x20;

You now have an Ockam Node running in your VPC. As before, this Node will have

1. a set of private key Identifiers, stored in a local Vault
2. a Membership Credential that will allow this Ockam Node to join your Project in Orchestrator.&#x20;

<figure><img src=".gitbook/assets/image (1) (1).png" alt=""><figcaption></figcaption></figure>

## Create a Portal Outlet in this Ockam Node

{% code fullWidth="false" %}
```sh
ockam tcp-outlet create --to 5432
```
{% endcode %}

An Outlet is created in the Ockam Node and a raw TCP connection is created to the postgres server on localhost port 5432.

<figure><img src=".gitbook/assets/image (2).png" alt=""><figcaption></figcaption></figure>

## Create a Secure Channel to Orchestrator, and create a Relay in your Project

```
ockam relay create postgres
```

This command&#x20;

1. initiates an outgoing tcp connection from the Ockam Node in AWS to your Project in Ockam Orchestrator.&#x20;
2. creates a [Secure Channel](https://docs.ockam.io/reference/protocols/secure-channels) over the tcp connection.&#x20;
3. creates a Relay in your Project at the address: `postgres`

Notice that we didn’t have to change anything in the AWS network settings. It’s possible because Bank Corp’s network allows outgoing tcp connections to the Internet. We use this port to create the Secure Channel.

<figure><img src=".gitbook/assets/image (3).png" alt=""><figcaption></figcaption></figure>

## Create an Ockam Node in Azure

```bash
curl --proto '=https' --tlsv1.2 -sSfL https://install.command.ockam.io | bash
source "$HOME/.ockam/env"

ockam enroll
```

<figure><img src=".gitbook/assets/image (4).png" alt=""><figcaption></figcaption></figure>

## Create a Portal Inlet in this Node in Azure

```sh
ockam tcp-inlet create --from 15432 --via postgres
```

This command&#x20;

1. creates a tcp Portal Inlet.
2. creates a tcp listener on localhost port 15432.&#x20;
3. creates an outgoing tcp connection to your Project.&#x20;
4. creates a[ Secure Channel](https://docs.ockam.io/reference/protocols/secure-channels) to your Project over this tcp connection.&#x20;
5. creates an end-to-end Secure Channel from the Inlet to the Outlet in Bank Corp’s VPC via the Relay in your Project at address: `postgres`

Congrats! The psql microservice at Analysis Corp and the Postgres database at Bank Corp are connected with an Ockam Portal.  &#x20;

<figure><img src=".gitbook/assets/image (6).png" alt=""><figcaption></figcaption></figure>

## Local Query

```bash
psql --host localhost --port 15432
```

The psql service now has an end-to-end encrypted, mutually authenticated, secure channel connection with the postgres database on `localhost:15432`&#x20;

All of the data-in-motion is end-to-end[ encrypted](https://docs.ockam.io/reference/protocols/secure-channels) with strong forward secrecy as it moves through the Internet. The communication channel is[ mutually authenticated](https://docs.ockam.io/reference/protocols/secure-channels) and[ authorized](https://docs.ockam.io/reference/protocols/access-controls). Keys and Credentials are automatically rotated. Access to connect with postgres can be easily revoked.

<figure><img src=".gitbook/assets/image (8).png" alt=""><figcaption></figcaption></figure>

## There’s so much more….

This is just one simple example. Ockam’s stack of[ protocols](https://docs.ockam.io/reference/protocols) work together to ensure security, privacy, and trust in data. They can be combined and composed in all sorts of ways.&#x20;

In the next section we will dive into all sorts of ways to build portals across different infrastructures, networks, and applications.\


## The Trick behind Ockam's Magic, by our Founders

{% embed url="https://www.youtube.com/embed/ufevCYmn8Do?si=jbA3oS05KNZD2kAA" %}
