# Apply fine-grained permissions with Attribute-Based Access Control (ABAC)

Attribute-Based Access Control (ABAC) is an authorization strategy that grants or denies access based on attributes.

A subject’s request to perform an operation on a resource is granted or denied based on attributes of the **subject**, attributes of the **operation**, attributes of the **resource**, and attributes of the **environment**. Access is controlled using **policies** that are defined in terms of those attributes.

In this guide we’ll walk through a step-by-step [demo](apply-fine-grained-permissions-with-attribute-based-access-control-abac.md#step-by-step-walkthrough) of using Ockam to add policy driven, attribute-based access control to any application using cryptographically verifiable credentials.&#x20;

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

Credentials are issued over mutually authenticated, end-to-end secure channels and carry a cryptographic signature over an authenticated identifier and its attributes. This then allows a verifier to check signatures and authenticate attributes.

Once we have authenticated attributes, a resource owner can make trust decisions based on these attributes rooted in attestations by trusted authorities.

<figure><img src="../../.gitbook/assets/diagrams.004.jpeg" alt=""><figcaption><p>Please click the diagram to see a bigger version.</p></figcaption></figure>

### Credential Authorities and Enrollment Protocols

Any Ockam Identifier can issue credentials about another Identifier, however some credential authorities are central to the success and scale of a distributed application. For such authorities Ockam Orchestrator offers highly scalable and secure managed credential authorities as a cloud service.

We also have to consider how credentials are issued to a large number of application entities. Ockam offers several pluggable enrollment protocols. Once simple option is to use one-time-use enrollment tokens. This is a great option to enroll large fleets of applications, service, or devices. It is also easy to use with automated provisioning scripts and tools.

<figure><img src="../../.gitbook/assets/diagrams.003.jpeg" alt=""><figcaption><p>Please click the diagram to see a bigger version.</p></figcaption></figure>

## Step-by-Step Walkthrough

### Install Ockam Command

Ockam Command is our Command Line Interface (CLI) for interfacing with Ockam processes.&#x20;

{% tabs %}
{% tab title="Homebrew" %}
If you use Homebrew, you can install Ockam using brew:

```
brew install build-trust/ockam/ockam
```
{% endtab %}

{% tab title="Other Systems" %}
```shell
 curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/build-trust/ockam/develop/install.sh | sh
```

After the binary downloads, please move it to a location in your shell's `$PATH`, like `/usr/local/bin`.
{% endtab %}
{% endtabs %}

### Administrator

```bash
# Check that everything was installed by enrolling with Ockam Orchestrator.
#
# This will provision an End-to-End Encrypted Cloud Relay service for you in
# your `default` project at `/project/default`. 
ockam enroll

# This will output the newly provisioned project information.
# This project info file can be used on seperate machines
# to target a specific project.
ockam project information --output json > project.json
```

```bash
# Creates enrollment tokens for the three types of identities that 
# will be created and used within this example
cp1_token=$(ockam project enroll --attribute component=control)
ep1_token=$(ockam project enroll --attribute component=edge)
x_token=$(ockam project enroll --attribute component=x)
```

### Control Plane

```bash
# In a seperate terminal window:
# Start an application service, listening on a local ip and port, that clients
# would access through the cloud encrypted relay. We'll use a simple http server
# for this first example but this could be any other application service.
python3 -m http.server --bind 127.0.0.1 5000
```

```bash
# Create an identity and authenticate the identity for this control plane
# with the Orchestator project.
ockam identity create control_identity
ockam project authenticate --token $cp1_token --identity control_identity

# Create a node targeting the project as the control identity.
ockam node create control_plane1 --project-path project.json --identity control_identity

# Set a policy, create the tcp-outlet and forwarder.
ockam policy create --at control_plane1 --resource tcp-outlet --expression '(= subject.component "edge")'
ockam tcp-outlet create --at /node/control_plane1 --from /service/outlet --to 127.0.0.1:5000
ockam forwarder create control_plane1 --at /project/default --to /node/control_plane1
```

### Edge Plane

<pre class="language-bash"><code class="lang-bash"># Create an identity and authenticate the identity for this edge plane
# with the Orchestator project.
ockam identity create edge_identity
ockam project authenticate --token $ep1_token --identity edge_identity
<strong>
</strong><strong># Create a node targeting the project as the edge identity.
</strong><strong>ockam node create edge_plane1 --project-path project.json --identity edge_identity
</strong>
# Set a policy, and create the tcp-inlet.
ockam policy create --at edge_plane1 --resource tcp-inlet --expression '(= subject.component "control")'
ockam tcp-inlet create --at /node/edge_plane1 --from 127.0.0.1:7000 --to /project/default/service/forward_to_control_plane1/secure/api/service/outlet
</code></pre>

```bash
# Send a request to our tcp-inlet at the `edge_plane1` node.
#
# This request will successfully be forwarded through the Ockam Orchestrator
# project to the `control_plane1` node and out to the python server
# all with full end-to-end encryption and Attribute-Based Access Control.
curl --fail --head --max-time 10 127.0.0.1:7000
```

The following is denied:

```bash
# Create an identity and authenticate the identity for this x node
# with the Orchestator project.
#
# This identity will use the enrollment token that has the attribute of
# `component=x` attached
ockam identity create x_identity
ockam project authenticate --token $x_token --identity x_identity

# Create a node targeting the project as the x identity.
ockam node create x --project-path project.json --identity x_identity

# Set a policy and create a new tcp-inlet for node x.
ockam policy create --at x --resource tcp-inlet --expression '(= subject.component "control")'
ockam tcp-inlet create --at /node/x --from 127.0.0.1:8000 --to /project/default/service/forward_to_control_plane1/secure/api/service/outlet

# Sends a request to our `x` tcp-inlet and will be denied (this will timeout)
curl --fail --head --max-time 10 127.0.0.1:8000
```

