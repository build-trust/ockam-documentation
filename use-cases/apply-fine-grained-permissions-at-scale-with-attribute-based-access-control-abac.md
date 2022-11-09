# Apply fine-grained permissions, at scale, with Attribute-Based Access Control (ABAC)

Attribute-Based Access Control (ABAC) is an authorization strategy that grants or denies access based on attributes.

A subject’s request to perform an operation on a resource is granted or denied based on attributes of the **subject**, attributes of the **operation**, attributes of the **resource**, and attributes of the **environment**. This is driven based on **policies** that define and enforced based on those attributes.

In this guide we’ll walk through

## Background

Modern applications are distributed and have an unwieldy number of interconnections that must trustfully exchange data and instructions.

In order to trust information or instructions, that are received over the network, applications must **authenticate** all senders and **verify the integrity of data** **received** to assert what was received is exactly what was sent — free from errors or en-route tampering.

Applications must also decide if a sender of a request is **authorized** to trigger the requested action or view the requested data.

In scenarios where human users are authenticating with cloud services, we have some mature protocols like OAuth 2.0 and OpenID Connect (OIDC) that help tackle parts of the problem. However, majority of data that flows within modern applications doesn’t involve humans. Microservices interact with other microservices, devices interact with other devices and cloud services, internal services interact with partner systems and infrastructure services etc.

**Secure** **by-design** applications must ensure that all machine-to-machine application layer communication is authenticated and authorized. For this, **applications must prove identifiers and attributes.**

Ockam makes it simple to safely generate unique **cryptographically provable identifiers** and store their private keys in safe vaults. Ockam Secure Channels guarantee end-to-end data integrity and enable **mutual authentication** using these cryptographically provable identifiers.









<figure><img src="../.gitbook/assets/diagrams.003.jpeg" alt=""><figcaption><p>Please click the diagram to see a bigger version.</p></figcaption></figure>

<figure><img src="../.gitbook/assets/diagrams.004.jpeg" alt=""><figcaption><p>Please click the diagram to see a bigger version.</p></figcaption></figure>

### Administrator

```bash
ockam enroll
ockam project information --output json > project.json
```

```bash
cp1_token=$(ockam project enroll --attribute component=control)
ep1_token=$(ockam project enroll --attribute component=edge)
x_token=$(ockam project enroll --attribute component=x)
```

### Control Plane

```
python3 -m http.server --bind 127.0.0.1 5000
```

```bash
ockam node create control_plane1 --project project.json --enrollment-token $cp1_token
ockam policy set --at control_plane1 --resource tcp-outlet --expression '(= subject.component "edge")'
ockam tcp-outlet create --at /node/control_plane1 --from /service/outlet --to 127.0.0.1:5000
ockam forwarder create control_plane1 --at /project/default --to /node/control_plane1
```

### Edge Plane

```bash
ockam node create edge_plane1 --project project.json --enrollment-token $ep1_token
ockam policy set --at edge_plane1 --resource tcp-inlet --expression '(= subject.component "control")'
ockam tcp-inlet create --at /node/edge_plane1 --from 127.0.0.1:7000 --to /project/default/service/forward_to_control_plane1/secure/api/service/outlet
```

```
curl --fail --head --max-time 10 127.0.0.1:7000
```

The following is denied:

```bash
ockam node create x --project project.json --enrollment-token $x_token
ockam policy set --at x --resource tcp-inlet --expression '(= subject.component "control")'
ockam tcp-inlet create --at /node/x --from 127.0.0.1:8000 --to /project/default/service/forward_to_control_plane1/secure/api/service/outlet
curl --fail --head --max-time 10 127.0.0.1:8000
```

