---
description: >-
  Scale mutual trust using lightweight, short-lived, revokable, attribute-based
  credentials.
---

# Verifiable Credentials

Trust and authorization decisions must be anchored in some pre-existing knowledge.

In the previous section about Ockam [Secure Channels](secure-channels.md) we ran an example of [mutual authorization](secure-channels.md#mutual-authorization) using pre-existing knowledge of Ockam [Identifiers](identities.md#identifier).

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
