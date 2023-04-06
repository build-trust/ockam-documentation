---
description: >-
  Scale mutual trust using lightweight, short-lived, revokable, attribute-based
  credentials.
---

# Verifiable Credentials

Ockam Secure Channels enable you to setup mutually authenticated and end-to-end encrypted communication. Once a channel is established, it has the following guarantees:

1. **Authenticity:** Each end of the channel knows that messages received on the channel must have been sent by someone who possesses the secret keys of specific Ockam Cryptographic Identifier.
2. **Integrity:** Each end of the channel knows that the messages received on the channel could not have been tapered en-route and are exactly what was sent by the authenticated sender at the other end of the channel.
3. **Confidentiality:**  Each end of the channel knows that the contents of messages received on the channel could not have been observed en-route between the sender and the receiver.

These guarantees however don't automatically imply trust. They don't tell us if a particular sender is trusted to inform us about a particular topic or if the sender is authorized to get a response to a particular request.

One way to create trust and authorize requests would be to use Access Control Lists (ACLs), where every receiver of messages would have a preconfigured list of identifiers that are trusted to inform about a certain topic or trigger certain requests. This approach works but doesn't scale very well. It becomes very cumbersome to manage mutual trust if you have more that a few nodes communicating with each other.

Another, and significantly more scalable, approach is to use Ockam <mark style="color:orange;">Credentials</mark> combined with <mark style="color:orange;">Attribute Based Access Control (ABAC)</mark>. In this setup every participant starts off by trusting a single Credential Issuer to be the authority on the attributes of an Identifier. This authority issues cryptographically signed credentials to attest to these attributes. Participants can then exchange and authenticate each others’ credentials to collect authenticated attributes about an identifier. Every participant uses these authenticated attributes to make authorization decisions based on attribute-based access control policies.

Let’s walk through a example of setting up ABAC using cryptographically verifiable credentials.

```sh
» ockam identity create authority
» ockam identity show authority > authority.identifier
» ockam identity show authority --full --encoding hex > authority

» ockam identity create i1 
» ockam identity show i1 > i1.identifier
» ockam credential issue --as authority --for $(cat i1.identifier) --attribute city="New York" --encoding hex > i1.credential
» ockam credential store c1 --issuer $(cat authority.identifier) --credential-path i1.credential

» ockam identity create i2
» ockam identity show i2 > i2.identifier
» ockam credential issue --as authority \
	--for $(cat i2.identifier) --attribute city="San Francisco" \
	--encoding hex > i2.credential
» ockam credential store c2 --issuer $(cat authority.identifier) --credential-path i2.credential

» ockam node create n1 --identity i1 --authority-identity $(cat authority)
» ockam node create n2 --identity i2 --authority-identity $(cat authority) --credential c2

» ockam secure-channel create --from n1 --to /node/n2/service/api --credential c1 \
    | ockam message send hello --from n1 --to -/service/uppercase
```
