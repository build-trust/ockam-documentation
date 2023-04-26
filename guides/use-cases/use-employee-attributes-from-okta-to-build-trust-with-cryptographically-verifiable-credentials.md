---
description: Authenticate and authorize every access decision.
---

# Use employee attributes from Okta to Build Trust with Cryptographically Verifiable Credentials

In this guide, we’ll step through a demo of how workforce identities in Okta can be combined with application identities in Ockam to bring policy driven, attribute-based access control of distributed applications – using cryptographically verifiable credentials.

<figure><img src="../../.gitbook/assets/diagrams.003 (1).jpeg" alt=""><figcaption><p>Please click the diagram to see a bigger version.</p></figcaption></figure>

## Background

Modern applications are distributed and have an unwieldy number of interconnections that must trustfully exchange data and instructions.

In order to trust information or instructions, that are received over the network, applications must **authenticate** all senders and **verify the integrity of data** **received** to assert what was received is exactly what was sent — free from errors or en-route tampering.

Applications must also decide if a sender of a request is **authorized** to trigger the requested action or view the requested data.

In scenarios where human users are authenticating with cloud services, we have some mature protocols like OAuth 2.0 and OpenID Connect (OIDC) that help tackle parts of the problem. However, majority of data that flows within modern applications doesn’t involve humans. Microservices interact with other microservices, devices interact with other devices and cloud services, internal services interact with partner systems and infrastructure services etc.

**Secure** **by-design** applications must ensure that all machine-to-machine application layer communication is authenticated and authorized. For this, **applications must prove identifiers and attributes.**

### Cryptographically Provable Identifiers

Ockam makes it simple to safely generate unique **cryptographically provable identifiers** and store their private keys in safe vaults. Ockam Secure Channels enable **mutual authentication** using these cryptographically provable identifiers.

On this foundation of mutually authenticated secure channels that guarantee end-to-end data authenticity, integrity and confidentiality, we give you tools to make fine-grained trust and authorization decisions.

One simple model of trust and authorization that is possible using only cryptographically provable identifiers is Access Control Lists (ACLs). A resource server is given a list of identifiers that it will allow access to a resource through an authenticated channel. This works great for simple scenarios but is hard to scale. As new clients or users need access to this resource, the access control list has to updated.

A much more powerful and scalable model becomes feasible with cryptographically provable credentials

### Authenticated Attributes and Cryptographic Credentials

When making fine-grained trust and access control decisions, applications often need to reason about the properties or attributes of an entity that is requesting access to a resource or reporting some data. For example, an application may require that its inventory micorservice is the only service that is allowed to report the current status of inventory. For this to work, applications need to a way to authenticate attributes.

Ockam enables attribute authentication using **cryptographically verifiable credentials.**

A credential **Verifier** trusts the public identifier of a credential **Authority**. A **Prover** that wishes to authenticate an attribute to this verifier gets a cryptographically signed credential from this same credential authority. By issuing a credential, the authority attests to one or more attributes of the prover. For example the authority may attest that a particular identifier has the attributes `service-type=inventory, location="New York"` .

Credentials are issued over mutually authenticated, end-to-end secure channels and carry a cryptographic signature over an authenticated identifier and its attributes. This then allows a verifier to check signatures and authenticate attributes.

Once we have authenticated attributes, a resource owner can make trust decisions based on these attributes rooted in attestations by trusted authorities.

<figure><img src="../../.gitbook/assets/diagrams.004.jpeg" alt=""><figcaption><p>Please click the diagram to see a bigger version.</p></figcaption></figure>

### Credential Authorities and Enrollment Protocols

Any Ockam Identifier can issue credentials about another Identifier, however some credential authorities are central to the success and scale of a distributed application. For such authorities Ockam Orchestrator offers highly scalable and secure managed credential authorities as a cloud service.

We also have to consider how credentials are issued to a large number of application entities. Ockam offers several pluggable enrollment protocols. Once simple option is to use one-time-use enrollment tokens. This is a great option to enroll large fleets of applications, service, or devices. It is also easy to use with automated provisioning scripts and tools.

<figure><img src="../../.gitbook/assets/diagrams.003.jpeg" alt=""><figcaption><p>Please click the diagram to see a bigger version.</p></figcaption></figure>

### Okta Add-On for Ockam Orchestrator

For most enterprises, workforce identities are already defined in enterprise identity systems like Okta. Ockam Orchestrator offers an Okta Add-On that uses OIDC to allows enterprise employees to get Ockam credentials using their regular corporate login.

Their user profile information like department, city, team etc. is included in the credential and securely attested by the Credential Authority.

This combination is incredibly powerful. It allows **employees to get just-in-time, short lived, fine-grained revocable credentials to only the application components that they need to access.** It eliminates long lived static keys and credentials from being stored on work machines.

<figure><img src="../../.gitbook/assets/diagrams.003 (1).jpeg" alt=""><figcaption><p>Please click the diagram to see a bigger version.</p></figcaption></figure>

## Step-by-Step Walkthrough

Let's walkthrough a simple example of Okta + Ockam in action.

We have a distributed application which has micro-service components running in San Francisco and New York. These components have Ockam Identities and Credentials and communicating trustfully using Ockam Secure Channels.

There is a problem in one of the micro-services in San Francisco and we need to give Alice (an engineer from San Francisco) secure, short lived, revocable access to just that service and nothing more.

First we'll create our application components and then see how to give access to the Alice.

### Setup

If you use Homebrew, you can install Ockam using `brew`.

```bash
brew install build-trust/ockam/ockam
```

Otherwise, you can download our latest architecture specific pre-compiled binary by running:

```shell
curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/build-trust/ockam/develop/install.sh | sh
```

After the binary downloads, please move it to a location in your shell's `$PATH`, like `/usr/local/bin`.

### Administrator

Next we provision our system. We enroll with Ockam Orchestrator, enable the Okta Add-On and export the project configuration to share with our application machines Machine 1 and 2.

```bash
ockam enroll
ockam project addon configure okta \
  --tenant https://trial-9434859.okta.com/oauth2/default --client-id 0oa2pi8no6Kb04frP697 \
  --attribute email --attribute city --attribute department

ockam project information --output json > project.json
```

This will create a managed Credential Authority for our project.

Next we generate two one-time-use enrollment tokens to enable Machine 1 and 2 to enroll and get credentials. Notice how we specify the attributes to attest for these two machines - `city` and `application`

```
m1_token=$(ockam project enroll --attribute application="Smart Factory" --attribute city="San Francisco")
m2_token=$(ockam project enroll --attribute application="Smart Factory" --attribute city="New York")
```

### Machine 1 in New York

We'll represent the application service on Machine 1 with a simple http server listening on port `5000` but this could be any application service:

```
python3 -m http.server --bind 127.0.0.1 5000
```

Next we transfer project configuration and one enrollment token to Machine 1 and use that to create and Ockam node that will run as a sidecar process next to our application service.

```bash
ockam identity create m1
ockam project authenticate --token $m1_token --identity m1 --project-path project.json
ockam node create m1 --project-path project.json --identity m1
ockam policy create --at m1 --resource tcp-outlet \
  --expression '(or (= subject.application "Smart Factory") (and (= subject.department "Field Engineering") (= subject.city "San Francisco")))'
ockam tcp-outlet create --at /node/m1 --from /service/outlet --to 127.0.0.1:5000
ockam relay create m1 --at /project/default --to /node/m1
```

We then set an attribute based policy on the the tcp-outlet that delivers traffic to our application service. This policy says to allow requests if the subject (the entity requesting access) is part of the same application or if the subject is a Field Engineer based in San Francisco.

```
(or (= subject.application "Smart Factory")
    (and (= subject.department "Field Engineering") (= subject.city "San Francisco")))
```

The first part of the policy allows various application component services to communicate with each other. The second part is what will enable Alice. However, note that there is no mention of Alice here, only a department and a city.

### Machine 2 in San Francisco

We'll represent the application service on Machine 2 with a simple http server listening on port 6`000` but this could be any application service:

```
python3 -m http.server --bind 127.0.0.1 6000
```

Next we transfer project configuration and one enrollment token to Machine 2 and use that to create and Ockam node that will run as a sidecar process next to our application service.

```bash
ockam identity create m2
ockam project authenticate --token $m2_token --identity m2 --project-path project.json
ockam node create m2 --project-path project.json --identity m2
ockam policy create --at m2 --resource tcp-outlet \
  --expression '(or (= subject.application "Smart Factory") (and (= subject.department "Field Engineering") (= subject.city "New York")))'
ockam tcp-outlet create --at /node/m2 --from /service/outlet --to 127.0.0.1:6000
ockam relay create m2 --at /project/default --to /node/m2
```

Same as before, we then set an attribute based policy on the the tcp-outlet that delivers traffic to our application service. This policy says to allow requests if the subject (the entity requesting access) is part of the same application or if the subject is a Field Engineer based in New York.

```
(or (= subject.application "Smart Factory")
    (and (= subject.department "Field Engineering") (= subject.city "New York")))
```

### Engineer for San Francisco

There is a problem in one of the micro-services in San Francisco and we need to give Alice (an engineer from San Francisco) secure, short lived, revocable access to just that service and nothing more.

Since the Okta Add-On is enabled. Alice can simple start a node within the project and authenticate.

```bash
ockam node create alice --project-path project.json
ockam project authenticate --project-path project.json --okta
ockam policy create --at alice --resource tcp-inlet --expression '(= subject.application "Smart Factory")'
```

The `project authenticate` command will launch Okta login and when it completes return a an Ockam cryptographic credential that includes the city and department attributes of Alice's profile in Okta Universal Directory. Only these two attributes are attested because the administrator specified those two attributes when enabling the Okta Add-On.

<figure><img src="../../.gitbook/assets/200395627-827d672a-2140-4752-a8d5-526ec5f0be68.png" alt=""><figcaption><p>User Profile in Okta</p></figcaption></figure>

Alice's `city` in Okta is "San Francisco". Her request to access Machine 1 in San Francisco is allowed

```
ockam tcp-inlet create --at /node/alice --from 127.0.0.1:8000 \
  --to /project/default/service/forward_to_m1/secure/api/service/outlet
curl --head 127.0.0.1:8000
```

Her request to access Machine 2 in New York is denied.

```
ockam tcp-inlet create --at /node/alice --from 127.0.0.1:9000 \
  --to /project/default/service/forward_to_m2/secure/api/service/outlet
curl --head 127.0.0.1:9000

# this will do nothing and eventually timeout
```

When new employees join the Field Engineering team in San Francisco, they will get an Okta workforce identity and can also request access to services they are responsible for in San Francisco without any change to the system.

These attribute based policies can easily span the spectrum of very simple to be highly fine-grained and dynamic depending on the needs of an application. At the same time, this approach is highly scalable because it decouples enterprise identity administration form an application's trust policies.
