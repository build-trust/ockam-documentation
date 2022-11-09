---
description: Authenticate and authorize every access decision.
---

# Use employee attributes from Okta to Build Trust with Cryptographically Verifiable Credentials



<figure><img src="../.gitbook/assets/diagrams.003 (1).jpeg" alt=""><figcaption><p>Please click the diagram to see a bigger version.</p></figcaption></figure>

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

A credential **Verifier** trusts the public identifier of a credential **Authority**. A **Prover** that wishes to authenticate an attribute to this verifier gets a cryptographically signed credential from this same credential authority. By issuing a credential, the authority attests to one or more attributes of the prover. For example the authority may attest that a particular identifier has the attributes `service-type=inventory, location="New York"`  &#x20;

<figure><img src="../.gitbook/assets/diagrams.004.jpeg" alt=""><figcaption><p>Please click the diagram to see a bigger version.</p></figcaption></figure>



<figure><img src="../.gitbook/assets/diagrams.003.jpeg" alt=""><figcaption><p>Please click the diagram to see a bigger version.</p></figcaption></figure>



##

## Step-by-Step Walkthrough

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

#### Administrator

```bash
ockam enroll
ockam project addon configure okta \
  --tenant https://trial-9434859.okta.com/oauth2/default --client-id 0oa2pi8no6Kb04frP697 \
  --attribute email --attribute city --attribute department

ockam project information --output json > project.json
```

```
m1_token=$(ockam project enroll --attribute application="Smart Factory" --attribute city="San Francisco")
m2_token=$(ockam project enroll --attribute application="Smart Factory" --attribute city="New York")
```

#### Machine 1 in New York

```
python3 -m http.server --bind 127.0.0.1 5000
```

```bash
ockam node create m1 --project project.json --enrollment-token $m1_token
ockam policy set --at m1 --resource tcp-outlet \
  --expression '(or (= subject.application "Smart Factory") (and (= subject.department "Field Engineering") (= subject.city "San Francisco")))'
ockam tcp-outlet create --at /node/m1 --from /service/outlet --to 127.0.0.1:5000
ockam forwarder create m1 --at /project/default --to /node/m1
```

#### Machine 2 in San Francisco

```
python3 -m http.server --bind 127.0.0.1 6000
```

```bash
ockam node create m2 --project project.json --enrollment-token $m2_token
ockam policy set --at m2 --resource tcp-outlet \
  --expression '(or (= subject.application "Smart Factory") (and (= subject.department "Field Engineering") (= subject.city "New York")))'
ockam tcp-outlet create --at /node/m2 --from /service/outlet --to 127.0.0.1:6000
ockam forwarder create m2 --at /project/default --to /node/m2
```

#### Platform Engineer for San Francisco

```bash
ockam node create alice --project project.json
ockam project authenticate --project project.json
ockam policy set --at alice --resource tcp-inlet --expression '(= subject.application "Smart Factory")'
```

The following is allowed:

```
ockam tcp-inlet create --at /node/alice --from 127.0.0.1:8000 --to /project/default/service/forward_to_m1/secure/api/service/outlet
curl --head 127.0.0.1:8000
```

The following is denied:

```
ockam tcp-inlet create --at /node/alice --from 127.0.0.1:9000 --to /project/default/service/forward_to_m2/secure/api/service/outlet
curl --head 127.0.0.1:9000
```
