---
description: >-
  Scale mutual trust using lightweight, short-lived, revokable, attribute-based
  credentials.
---

# Verifiable Credentials

Trust and authorization decisions must be anchored in some pre-existing knowledge.

In the previous section about Ockam [Secure Channels](secure-channels.md) we ran an example of [mutual authorization](secure-channels.md#mutual-authorization) using pre-existing knowledge of Ockam [Identifiers](identities.md#identifier).

In this example `n1 knows i2` and `n2 know i1`:

```
» ockam node delete --all

» ockam identity create i1
» ockam identity show i1 > i1.identifier
» ockam node create n1 --identity i1

» ockam identity create i2
» ockam identity show i2 > i2.identifier
» ockam node create n2 --identity i2

» ockam secure-channel-listener create l --at n2 \
    --identity i2 --authorized $(cat i1.identifier)

» ockam secure-channel create \
    --from n1 --to /node/n2/service/l \
    --identity i1 --authorized $(cat i2.identifier) \
      | ockam message send hello --from n1 --to -/service/uppercase
HELLO
```

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

## Managed Authorities

```
» ockam node delete --all
» ockam project information --output json > project.json

» ockam node create a --project project.json
» ockam node create b --project project.json

» ockam forwarder create b --at /project/default --to /node/a
/service/forward_to_b

» ockam secure-channel create --from a --to /project/default/service/forward_to_b/service/api \
    | ockam message send hello --from a --to -/service/uppercase
HELLO
```
