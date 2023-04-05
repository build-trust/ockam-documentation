---
description: >-
  Scale mutual trust using lightweight, short-lived, revokable, attribute-based
  credentials.
---

# Credentials and Authorities

Ockam Secure Channels enable you to setup mutually authenticated and end-to-end encrypted communication. Once a channel is established, it has the following guarantees:

1. **Authenticity:** Each end of the channel knows that messages received on the channel must have been sent by someone who possesses the secret keys of specific Ockam Cryptographic Identifier.
2. **Integrity:** Each end of the channel knows that the messages received on the channel could not have been tapered en-route and are exactly what was sent by the authenticated sender at the other end of the channel.
3. **Confidentiality:**  Each end of the channel knows that the contents of messages received on the channel could not have been observed en-route between the sender and the receiver.

These guarantees however don't automatically imply trust. They don't tell us if a particular sender is trusted to inform us about a particular topic or if the sender is authorized to get a response to a particular request.

One way to create trust and authorize requests would be to use Access Control Lists (ACLs), where every receiver of messages would have a preconfigured list of identifiers that are trusted to inform about a certain topic or trigger certain requests. This approach works but doesn't scale very well. It becomes very cumbersome to manage mutual trust if you have more that a few nodes communicating with each other.

Another, and significantly more scalable, approach is to use Ockam <mark style="color:orange;">Credentials</mark> combined with <mark style="color:orange;">Attribute Based Access Control (ABAC)</mark>. In this setup every participant starts off by trusting a single Credential Issuer to be the authority on the attributes of an Identifier. This authority issues cryptographically signed credentials to attest to these attributes. Participants can then exchange and authenticate each others’ credentials to collect authenticated attributes about an identifier. Every participant uses these authenticated attributes to make authorization decisions based on attribute-based access control policies.

Let’s walk through a example of setting up ABAC using cryptographically verifiable credentials.

```sh
# Create Two identities
ockam identity create i1 
ockam identity show i1 > i1.id

ockam identity create i2
ockam identity show i2 > i2.id

# Create an identity that both i1, and i2 can trust
ockam identity create issuer
ockam identity show issuer > ia.id
ockam identity show issuer --full --encoding hex > authority

# issue and store credentials for i1
ockam credential issue --as issuer --for $(cat i1.id) --attribute city="New York" --encoding hex > i1.cred
ockam credential store i1-cred --issuer $(cat ia.id) --credential-path i1.cred

# issue credential for i2
ockam credential issue --as issuer --for $(cat i2.id) --attribute city="Dallas" --encoding hex > i2.cred
ockam credential store i2-cred --issuer $(cat ia.id) --credential-path i2.cred

# Create a node that trust issuer as a credential authority
ockam node create n1 --authority-identity $(cat authority)

# Create another node that trust and has a preset credential
ockam node create n2 --authority-identity $(cat authority) --identity i2 --credential i2-cred

# Create a secure channel between n1 and n2 
# n1 will present the credential provided within this command
# n2 will present the cerdential preset when created
ockam secure-channel create --from /node/n1 --to /node/n2/service/api --credential i1-cred \
 | ockam message send hello --from /node/n1 --to -/service/uppercase
```
